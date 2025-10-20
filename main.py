import os
import subprocess

def define_env(env):

    # Get the current git version description
    try:
        version = subprocess.check_output(["git", "describe", "--tags", "--always"], text=True).strip()
    except Exception:
        version = "unknown"

    env.variables["git_version"] = version

    # Macro to list Architecture Decision Records (ADRs)
    @env.macro
    def list_adrs():
        ADRDIR="decisions"
        adr_dir = os.path.join(env.conf['docs_dir'], ADRDIR)
        adrs = []
        for filename in sorted(os.listdir(adr_dir)):
            if filename.endswith('.md'):
                path = f'{ADRDIR}/{filename}'
                title = filename.replace('-', ' ').replace('.md', '')
                adrs.append(f"- [{title}]({path})")
        return '\n'.join(adrs)
