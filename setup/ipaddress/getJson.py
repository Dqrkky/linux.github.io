import subprocess
import json
import re

def get_ip_address_info(command=["ip", "address"]):
    result = subprocess.run(
        command,
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        return {"error": "Failed to execute 'ip address'"}
    interfaces = []
    current_iface = None
    for line in result.stdout.splitlines():
        line = line.strip()
        iface_match = re.match(r"^(\d+):\s+([\w@:.\-]+):\s+<(.+)>.*state\s+(\S+)", line)
        if iface_match:
            current_iface = {
                "name": iface_match.group(2),
                "flags": iface_match.group(3).split(','),
                "state": iface_match.group(4),
                "ipv4": [],
                "ipv6": [],
                "mac": None,
                "altname": None
            }
            interfaces.append(current_iface)
            continue
        if current_iface is None:
            continue
        if line.startswith("link/"):
            parts = line.split()
            if len(parts) >= 2:
                current_iface["mac"] = parts[1]
        elif line.startswith("altname"):
            current_iface["altname"] = line.split()[-1]
        elif line.startswith("inet "):
            parts = line.split()
            current_iface["ipv4"].append(parts[1])
        elif line.startswith("inet6 "):
            parts = line.split()
            current_iface["ipv6"].append(parts[1])
    return interfaces

if __name__ == "__main__":
    info = get_ip_address_info()
    print(json.dumps(info, indent=2))
