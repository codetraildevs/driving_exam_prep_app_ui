"""Verify replay safety for offline attempts against disposable MySQL."""
import json, os, subprocess, time, urllib.request, urllib.error
subprocess.run(["mysql", "-h", "127.0.0.1", "-u", "root", "wa_test", "-e", """
CREATE TABLE exam_results (
 id VARCHAR(36) PRIMARY KEY, userId VARCHAR(36), examId VARCHAR(36),
 score INT, totalQuestions INT, correctAnswers INT, timeSpent INT,
 answers TEXT, passed TINYINT, completedAt DATETIME, isFreeExam TINYINT,
 createdAt DATETIME, updatedAt DATETIME, questionResults TEXT
);
"""], env={**os.environ, "MYSQL_PWD": "test-password"}, check=True)
server = subprocess.Popen(["php", "-S", "127.0.0.1:8100", "backend/tests/offline_results_router.php"],
 env={**os.environ, "WHATSAPP_TEST_MODE": "1"}, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
def post(body, user="u1", expected=201):
    req = urllib.request.Request("http://127.0.0.1:8100/api/practice-results",
        data=json.dumps(body).encode(), headers={"Content-Type":"application/json",
        "X-Test-Role":"USER", "X-Test-User":user}, method="POST")
    try: res = urllib.request.urlopen(req)
    except urllib.error.HTTPError as error: res = error
    payload = json.load(res)
    assert res.status == expected, (res.status, payload)
    return payload.get("data")
try:
    body = {"userId":"u1", "examId":"177", "score":90, "totalQuestions":20, "correctAnswers":18,
      "timeSpent":100, "clientResultId":"fdd45678-1234-4567-8123-123456789012", "createdAt":"2026-01-10T12:00:00Z"}
    for _ in range(50):
        try:
            first = post(body)
            break
        except urllib.error.URLError: time.sleep(0.1)
    else: raise AssertionError("PHP test server did not start")
    second = post(body, expected=200)
    assert first["id"] == second["id"] == body["clientResultId"]
    post({**body, "userId":"u2"}, user="u2", expected=403)
    post({**body, "clientResultId":"invalid"}, expected=400)
    count = subprocess.check_output(["mysql", "-h", "127.0.0.1", "-u", "root",
      "-N", "wa_test", "-e", "SELECT COUNT(*) FROM exam_results"],
      env={**os.environ, "MYSQL_PWD":"test-password"}).decode().strip()
    assert count == "1", count
    post({k:v for k,v in body.items() if k != "clientResultId"})
    print("PASS: repeated attempts produce one record; ownership, validation and older clients supported")
finally:
    server.terminate()
    server.wait(timeout=5)
