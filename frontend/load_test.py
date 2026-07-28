import os
import sys

# Wrapper to execute frontend testing load test suite
script_dir = os.path.dirname(os.path.abspath(__file__))
ft_dir = os.path.join(script_dir, "frontend testing")
sys.path.insert(0, ft_dir)

from load_test import run_load_test_suite

if __name__ == "__main__":
    run_load_test_suite()
