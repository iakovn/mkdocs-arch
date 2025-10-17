import subprocess

def define_env(env):
    try:
        version = subprocess.check_output(["git", "describe", "--tags", "--always"], text=True).strip()
    except Exception:
        version = "unknown"

    env.variables["git_version"] = version
