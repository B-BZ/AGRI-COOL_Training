"""Three-panel plot (irradiance, room temperature, ice SOC) from an OpenModelica result file.

Usage:
    python plot_results.py AfternoonLoading_res.mat "Afternoon Loading (16:00)"

Requires numpy, scipy, matplotlib.
"""
import sys
import numpy as np
import scipy.io
import matplotlib.pyplot as plt


def load_om(fn):
    """Read an OpenModelica/Dymola v4 .mat result file into {name: (time, values)}."""
    m = scipy.io.loadmat(fn, chars_as_strings=False)
    trans = [''.join(r).rstrip() for r in m['Aclass']][3] == 'binTrans'
    if trans:
        names = [''.join(c).rstrip() for c in zip(*m['name'])]
    else:
        names = [''.join(r).rstrip() for r in m['name']]
    info = m['dataInfo'] if trans else m['dataInfo'].T
    d2 = m['data_2'] if trans else m['data_2'].T
    d1 = m['data_1'] if trans else m['data_1'].T
    t = d2[0]
    out = {}
    for i, n in enumerate(names):
        blk, col = int(info[0][i]), int(info[1][i])
        if col == 0:
            continue
        sgn = np.sign(col)
        row = abs(col) - 1
        if blk == 2:
            out[n] = (t, sgn * d2[row])
        else:  # parameter: constant over time
            out[n] = (t, np.full_like(t, sgn * d1[row][0]))
    return out


def main():
    fn = sys.argv[1] if len(sys.argv) > 1 else "ColdRoomSystem_res.mat"
    title = sys.argv[2] if len(sys.argv) > 2 else ""
    r = load_om(fn)
    t, G = r["G"]
    days = t / 86400.0
    _, Troom = r["room_degC"]
    _, soc = r["SOC"]

    fig, ax = plt.subplots(3, 1, figsize=(5.5, 6.5), sharex=True)
    day = G > 5
    for a in ax:
        a.fill_between(days, 0, 1, where=day, transform=a.get_xaxis_transform(),
                       color="#fff6d5", step="mid")
        a.fill_between(days, 0, 1, where=~day, transform=a.get_xaxis_transform(),
                       color="#ececec", step="mid")
    ax[0].plot(days, G, color="orange", lw=2, label="Solar irradiance")
    ax[0].set_ylabel("Irradiance\n[W/m²]")
    ax[1].plot(days, Troom, color="tab:blue", lw=2, label="Cold room temperature")
    ax[1].set_ylabel("T [°C]")
    ax[2].plot(days, soc, color="tab:green", lw=2, label="SOC")
    ax[2].set_ylabel("SOC [-]")
    ax[2].set_ylim(0, 1.15)
    ax[2].set_xlabel("Time [days]")
    for a in ax:
        a.legend(loc="upper right")
        a.set_xlim(days[0], days[-1])
    if title:
        fig.suptitle(title, fontweight="bold")
    fig.tight_layout()
    out = fn.replace(".mat", ".png")
    fig.savefig(out, dpi=200)
    print("saved", out)
    plt.show()


if __name__ == "__main__":
    main()
