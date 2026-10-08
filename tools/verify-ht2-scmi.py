#!/usr/bin/env python3
"""Check the audited HT2 BL31/CPU clock contract in a compiled DTB."""
import subprocess
import sys


def get(dtb, node, prop, kind="s"):
    return subprocess.check_output(
        ["fdtget", "-t", kind, dtb, node, prop], text=True
    ).strip()


def verify(dtb):
    scmi = "/firmware/scmi"
    props = subprocess.check_output(["fdtget", "-p", dtb, scmi], text=True).split()
    assert "status" not in props or get(dtb, scmi, "status") == "okay", "SCMI must remain enabled"
    assert get(dtb, scmi, "compatible") == "arm,scmi-smc"
    assert get(dtb, scmi, "arm,smc-id", "x") == "82000010"
    clock = get(dtb, scmi + "/protocol@14", "phandle", "u")
    for cpu in range(4):
        actual = get(dtb, f"/cpus/cpu@{cpu}", "clocks", "u")
        assert actual == clock + " 21", f"cpu{cpu}: expected audited SCMI CPU clock 21, got {actual}"
    assert get(dtb, "/reserved-memory/shmem@10f000", "reg", "x") == "0 10f000 0 100"
    print("HT2 SCMI contract PASS: CPU0-3 clock 21, SMC 0x82000010, audited shmem")


if __name__ == "__main__":
    verify(sys.argv[1])
