<?php
/** Local regression against the users DDL shipped with this application.
 * Run: php backend/tests/irembo_schema_test.php
 * Uses only a newly created disposable database. Never deploy this file.
 */
if (PHP_SAPI !== 'cli') exit(1);
$password = getenv('IREMBO_TEST_PASSWORD');
$password = $password === false ? 'test-password' : $password;
if (getenv('IREMBO_TEST_EMPTY_PASSWORD') === '1') $password = '';
$db = new PDO('mysql:host=127.0.0.1;charset=utf8mb4', 'root', $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$database = 'irembo_test_' . bin2hex(random_bytes(6));
$db->exec("CREATE DATABASE `$database` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci");
$server = null;
function check($condition, string $message): void {
    if (!$condition) throw new RuntimeException($message);
}
function request(string $method, string $path = '', ?array $body = null, string $user = 'u1', int $expected = 200): array {
    $curl = curl_init('http://127.0.0.1:18101/api/irembo-requests' . $path);
    curl_setopt_array($curl, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 10,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json', 'X-Test-User: ' . $user]]);
    if ($body !== null) curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($body));
    $raw = curl_exec($curl);
    $status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);
    check($status === $expected, "$method $path: expected $expected, got $status: $raw");
    return json_decode($raw, true)['data'] ?? [];
}
try {
    $db->exec("USE `$database`");
    $dump = file_get_contents(__DIR__ . '/../rwandatr_traffic_rules_dbs.sql');
    check(preg_match('/CREATE TABLE `users` \(.*?\) ENGINE=.*?;/s', $dump, $match) === 1, 'users DDL missing');
    $db->exec($match[0]);
    $db->exec(file_get_contents(__DIR__ . '/../migrations/20261026_irembo.sql'));
    // Keep production defaults: active accounts can have legacy isBlocked=1.
    $insert = $db->prepare('INSERT INTO users (id,fullName,phoneNumber,deviceId,role,createdAt,updatedAt) VALUES (?,?,?,?,?,NOW(),NOW())');
    foreach ([['u1','Applicant','0788123456','device1','USER'],['u2','Other applicant','0788123457','device2','USER'],['a1','Admin','0788123458','device3','ADMIN'],['m1','Manager','0788123459','device4','MANAGER']] as $user) $insert->execute($user);
    $env = array_merge(getenv(), ['IREMBO_TEST_MODE'=>'1', 'IREMBO_TEST_DB'=>$database, 'IREMBO_TEST_PASSWORD'=>$password]);
    $server = proc_open([PHP_BINARY, '-S', '127.0.0.1:18101', __DIR__.'/irembo_router.php'],
        [0=>['pipe','r'], 1=>['file',PHP_OS_FAMILY === 'Windows' ? 'NUL' : '/dev/null','a'], 2=>['file',PHP_OS_FAMILY === 'Windows' ? 'NUL' : '/dev/null','a']], $pipes, null, $env);
    check(is_resource($server), 'Could not start test server');
    fclose($pipes[0]);
    for ($i=0; $i<50; $i++) {
        $socket = @fsockopen('127.0.0.1',18101,$errno,$error,0.1);
        if ($socket) { fclose($socket); break; }
        usleep(100000);
    }
    check(request('GET')['total'] === 0, 'Initial applicant list');
    $staff = request('GET','/staff',null,'a1');
    check(array_column($staff,'name') === ['Admin','Manager'], 'Staff display names');
    $form = ['requestKey'=>'11111111-1111-4111-8111-111111111111','fullName'=>'Applicant','phoneNumber'=>'0788123456','nationalId'=>'0123456789012345','dob'=>'1990-01-01','service'=>'Provisoire','examLanguage'=>'rw','district'=>'Gasabo'];
    $created = request('POST','',$form,'u1',201);
    check($created['status'] === 'Pending', 'Created status');
    check(request('POST','',$form,'u1',201)['id'] === $created['id'], 'Retry deduplication');
    $duplicate = array_merge($form, ['requestKey'=>'22222222-2222-4222-8222-222222222222']);
    request('POST','',$duplicate,'u1',409);
    request('POST','',array_merge($duplicate,['service'=>'Permis','permisOption'=>'Automatic','provisoireCode'=>'12345']),'u1',409);
    check(request('GET')['total'] === 1, 'Applicant list after submission');
    check(request('GET','',null,'u2')['total'] === 0, 'Applicant isolation');
    $path = '/' . $created['id'];
    request('GET',$path,null,'u2',404);
    request('PUT',$path,['version'=>1,'status'=>'In Review','assignedStaffId'=>'m1','applicantMessage'=>'We received your request','internalNote'=>'Private note'],'a1');
    $list = request('GET','',null,'m1');
    check($list['items'][0]['assignedStaffName'] === 'Manager', 'Assigned staff name');
    $detail = request('GET',$path,null,'m1');
    check(array_unique(array_column($detail['messages'],'staffName')) === ['Admin'], 'Message author names');
    check(count($detail['audit']) === 2, 'Audit entries');
    $actors = array_column($detail['audit'],'actorName'); sort($actors);
    check($actors === ['Admin','Applicant'], 'Audit author names');
    $own = request('GET',$path);
    check(count($own['messages']) === 1 && !isset($own['audit']), 'Applicant message privacy');
    // Separate PHP processes use independent connections, unlike the single-threaded HTTP harness.
    $workerCode = <<<'PHP'
require $argv[1].'/../src/helpers.php';
require $argv[1].'/../src/SecurityUtils.php';
require $argv[1].'/../src/handlers/irembo.php';
$password=getenv('IREMBO_TEST_EMPTY_PASSWORD')==='1' ? '' : getenv('IREMBO_TEST_PASSWORD');
$db=new PDO('mysql:host=127.0.0.1;dbname='.getenv('IREMBO_TEST_DB').';charset=utf8mb4','root',$password,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$form=['requestKey'=>$argv[2],'fullName'=>'Concurrent applicant','phoneNumber'=>'0788123457','nationalId'=>'0123456789012345','dob'=>'1990-01-01','service'=>'Provisoire','examLanguage'=>'rw','district'=>'Gasabo'];
try { irCreate($db,['id'=>'u2','role'=>'USER'],$form); echo '201'; }
catch (Throwable $e) { echo $e->getCode(); }
PHP;
    $workers = [];
    foreach (['33333333-3333-4333-8333-333333333333','44444444-4444-4444-8444-444444444444'] as $key) {
        $process = proc_open([PHP_BINARY,'-r',$workerCode,__DIR__,$key], [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $workerPipes, null, $env);
        check(is_resource($process), 'Could not start concurrency worker');
        fclose($workerPipes[0]);
        $workers[] = [$process,$workerPipes];
    }
    $statuses = [];
    foreach ($workers as [$process,$workerPipes]) {
        $statuses[] = trim(stream_get_contents($workerPipes[1]));
        $errors = stream_get_contents($workerPipes[2]);
        fclose($workerPipes[1]); fclose($workerPipes[2]);
        check(proc_close($process) === 0 && $errors === '', 'Concurrency worker failed: '.$errors);
    }
    sort($statuses);
    check($statuses === ['201','409'], 'Concurrent requests must produce exactly one creation');
    check(request('GET','',null,'u2')['total'] === 1, 'Concurrent submissions created one row');
    // Admin block/unblock uses isActive, not the legacy isBlocked column.
    $db->exec("UPDATE users SET isActive=0, isBlocked=0 WHERE id='u1'");
    request('GET','',null,'u1',403);
    request('POST','',$form,'u1',403);
    $db->exec("UPDATE users SET isActive=1 WHERE id='u1'");
    check(request('GET')['total'] === 1, 'Unblocked account access');
    $db->exec("UPDATE users SET isActive=0, isBlocked=0 WHERE id='m1'");
    request('GET','',null,'m1',403);
    check(array_column(request('GET','/staff',null,'a1'),'name') === ['Admin'], 'Inactive staff excluded');
    request('PUT',$path,['version'=>2,'assignedStaffId'=>'m1'],'a1',400);
    request('GET','',null,'missing-user',403);
    echo "PASS: real users schema; single submission per account, retry, lists, assignment, messages, audit and privacy\n";
} finally {
    if (is_resource($server)) { proc_terminate($server); proc_close($server); }
    // This identifier was generated above and cannot name an existing application database.
    $db->exec("DROP DATABASE `$database`");
}
