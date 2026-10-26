"""Run authentication regressions without production credentials or data."""
import json
import subprocess
for scenario, expected in [
    ("demo", 200), ("international", 200),
    ("regular-same", 200), ("regular-other", 401), ("inactive", 403),
    ("refresh-old", 200), ("refresh-new", 200),
]:
    result = json.loads(subprocess.check_output(["php", "backend/tests/demo_auth_case.php", scenario]))
    status = result.get("status", result.get("code"))
    assert status == expected, (scenario, result)
    if expected == 200:
        assert result["data"]["token"]
        assert result["data"]["refresh_token"]
    print("PASS:", scenario)
