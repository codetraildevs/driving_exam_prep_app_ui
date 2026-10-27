<?php
// Disposable CI harness. Never deploy this file.
if (PHP_SAPI !== 'cli-server' || getenv('IREMBO_TEST_MODE') !== '1') { http_response_code(404); exit(); }
class Logger { public static function error($m,$c=[]) {} }
class Env { public static function get($k,$d=null) { return $d; } }
require __DIR__.'/../src/ErrorHandler.php';
require __DIR__.'/../src/helpers.php';
require __DIR__.'/../src/SecurityUtils.php';
require __DIR__.'/../src/handlers/irembo.php';
if (empty($_SERVER['HTTP_X_TEST_USER'])) ErrorHandler::unauthorized();
$tokenData=['userId'=>$_SERVER['HTTP_X_TEST_USER'],'role'=>$_SERVER['HTTP_X_TEST_ROLE']??'USER'];
$testDatabase=getenv('IREMBO_TEST_DB') ?: 'irembo_test';
if (!preg_match('/^irembo_test(?:_[a-z0-9_]+)?$/D', $testDatabase)) { http_response_code(500); exit(); }
$testPassword=getenv('IREMBO_TEST_PASSWORD');
if (getenv('IREMBO_TEST_EMPTY_PASSWORD') === '1') $testPassword = '';
$conn=new PDO('mysql:host=127.0.0.1;dbname='.$testDatabase.';charset=utf8mb4','root',$testPassword === false ? 'test-password' : $testPassword,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_EMULATE_PREPARES=>false]);
foreach(require __DIR__.'/../src/routes.php' as [$method,$path,$handler]) {
 $params=[];
 if($handler==='iremboRequests' && $method===$_SERVER['REQUEST_METHOD'] && matchRoute($path,parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH),$params)){iremboRequests($conn,$params);exit();}
}
ErrorHandler::notFound();
