import numpy as np
import matplotlib.pyplot as plt
import os

fs = 10000
samples = 500
freqs = [950, 1100, 2000]
methods = ["direct", "optimized", "genvar"]

scale = 2**14

def read_file(name):
    if not os.path.exists(name):
        return None
    return np.loadtxt(name, dtype=int)

py_out = {}

for f in freqs:
    fname = f"python_output_{f}Hz.txt"
    data = read_file(fname)
    if data is not None:
        py_out[f] = data

ver_out = {}

for m in methods:
    ver_out[m] = {}
    for f in freqs:
        fname = f"verilog_{m}_{f}Hz.txt"
        data = read_file(fname)
        if data is not None:
            ver_out[m][f] = data

t = np.arange(samples) / fs * 1000

for m in methods:
    if m not in ver_out:
        continue

    fig, ax = plt.subplots(3,1, figsize=(10,8))
    fig.suptitle("Python vs Verilog (" + m + ")")

    for i,f in enumerate(freqs):
        a = ax[i]

        if f in py_out:
            py = py_out[f]
            n = min(len(py), samples)
            a.plot(t[:n], py[:n] / scale, label="python")

        if f in ver_out[m]:
            vl = ver_out[m][f]
            n = min(len(vl), samples)
            a.plot(t[:n], vl[:n] / scale, '--', label="verilog")

        a.set_title(str(f) + " Hz")
        a.set_xlabel("time (ms)")
        a.set_ylabel("amplitude")
        a.legend()
        a.grid(True)

    plt.tight_layout()
    name = "verification_" + m + ".png"
    plt.savefig(name)
    plt.show()
