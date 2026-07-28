import os
import subprocess
import sys
import unittest


class AppiumAndroidReportTests(unittest.TestCase):
    def test_appium_android_report_script_runs(self):
        repo_root = os.path.dirname(os.path.abspath(__file__))
        script_path = os.path.join(repo_root, "frontend testing", "appium_android_report.py")

        self.assertTrue(os.path.exists(script_path), f"Missing script: {script_path}")

        result = subprocess.run(
            [sys.executable, script_path],
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr or result.stdout)


if __name__ == "__main__":
    unittest.main()
