"""Integration checks against a disposable MySQL database, never production."""
import json
import os
import subprocess
import time
import urllib.request
import urllib.error

def sql(statement):
    subprocess.run(["mysql", "-h", "127.0.0.1", "-u", "root", "-e", statement],
                   env={**os.environ, "MYSQL_PWD": "test-password"}, check=True)

def request(method="GET", suffix="", data=None, role="ADMIN", user="root", status=200):
    headers = {"Content-Type": "application/json", "X-Test-DB-User": user}
    if role:
        headers["X-Test-Role"] = role
    req = urllib.request.Request("http://127.0.0.1:8099/api/whatsapp-groups" + suffix,
        data=None if data is None else json.dumps(data).encode(), headers=headers, method=method)
    try:
        response = urllib.request.urlopen(req)
    except urllib.error.HTTPError as error:
        response = error
    result = json.load(response)
    assert response.status == status, (method, response.status, result)
    assert result["success"] == (status < 400), result
    return result.get("data")

sql("""
CREATE DATABASE wa_test;
CREATE USER 'wa_crud'@'%' IDENTIFIED BY 'test-password';
CREATE USER 'wa_read'@'%' IDENTIFIED BY 'test-password';
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_test.* TO 'wa_crud'@'%';
GRANT SELECT ON wa_test.* TO 'wa_read'@'%';
""")
server = subprocess.Popen(["php", "-S", "127.0.0.1:8099", "backend/tests/whatsapp_router.php"],
    env={**os.environ, "WHATSAPP_TEST_MODE": "1"}, stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL)
try:
    for _ in range(50):
        try:
            request(role=None, status=401)
            break
        except urllib.error.URLError:
            time.sleep(0.1)
    else:
        raise AssertionError("PHP test server did not start")
    group = {"name": "Study group", "inviteUrl": "https://chat.whatsapp.com/TestInvite123"}
    # Unauthorized mutations must not touch storage.
    for method in ["POST", "PUT", "DELETE"]:
        request(method, "" if method == "POST" else "/missing", group, role="USER", status=403)
    # Missing table + no CREATE privilege returns a real error.
    request(user="wa_crud", status=500)
    assert request() == []  # automatic first-run table creation
    # Existing table works with CRUD privileges and no CREATE privilege.
    assert request(user="wa_crud") == []
    created = request("POST", data=group, user="wa_crud", status=201)
    suffix = "/" + created["id"]
    assert request(role="USER")[0]["name"] == group["name"]
    updated = {**group, "name": "Updated group"}
    request("PUT", suffix, updated, role="MANAGER", user="wa_crud")
    assert request()[0]["name"] == "Updated group"
    # Saving unchanged data remains successful.
    request("PUT", suffix, updated, user="wa_crud")
    for method in ["POST", "PUT", "DELETE"]:
        request(method, "" if method == "POST" else suffix, group, user="wa_read", status=500)
    assert request()[0]["name"] == "Updated group"
    request("POST", data={**group, "inviteUrl": "https://example.com"}, status=400)
    request("PUT", "/missing", group, status=404)
    request("DELETE", suffix, user="wa_crud")
    assert request() == []
    request("DELETE", suffix, status=404)
    # Read failure must not appear as an empty successful list.
    sql("GRANT INSERT ON wa_test.* TO 'wa_read'@'%'; REVOKE SELECT ON wa_test.* FROM 'wa_read'@'%'")
    request(user="wa_read", status=500)
    print("PASS: CRUD, roles, validation, missing records, missing table, restricted privileges and database failures")
finally:
    server.terminate()
    server.wait(timeout=5)
