#!/usr/bin/env python3
"""Fig 10. Task templates projected with PCA (linear) and UMAP (nonlinear), with bin-overlap counts.

Data file: data/task_templates.mat (shared with Fig 4)
    TEMPLATE.template.TMP1000.<TASK>.<MUSCLE>   task-specific muscle-activity template (1000 samples, n.u.)
    TASK = GRASP25, GRIP25, PRONATE25

The analysis uses the templates of the seven proximal muscles (SIGNALS), as in the paper: when distal
activity is reconstructed from proximal recordings, the proximal signals alone must identify the task.
Set SIGNALS = ALL_SIGNALS to repeat it with all 15 muscles.

Outputs (written to output/): Fig10.pdf and Fig10.png (the two-panel figure), fig10_overlap_matrices.pdf,
and the statistics printed to the terminal (Bartlett's test, KMO, explained variance, shared occupancy bins).
UMAP is stochastic across library versions; the numbers in the paper come from the pinned environment in
requirements.txt (umap-learn 0.5.12, random_state 12).
"""
from pathlib import Path

import numpy as np
import scipy.io as sio
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager
from sklearn.decomposition import PCA
from factor_analyzer import calculate_bartlett_sphericity, calculate_kmo
import umap

HERE = Path(__file__).resolve().parent
OUT = HERE / "output"
OUT.mkdir(exist_ok=True)

TRIAL_TYPES = ["GRASP25", "GRIP25", "PRONATE25"]
LABELS = ["grasp", "grip", "pronate"]
SIGNALS = ["DELT_A", "DELT_M", "DELT_P", "BIC_SH", "BIC_LO", "TRI_LAT", "TRI_LO"]          # as published
ALL_SIGNALS = SIGNALS + ["BRR", "FCR", "FDS", "FCU", "ECR", "EDC", "ECU", "ADP"]            # ADP = APB
COLORS = ["#F0665A", "#F2B35A", "#555555"]
NUM_BINS = 50
SEED = 12

# same typeface as the other figures (Helvetica; Arial if Helvetica is not installed)
available = {f.name for f in font_manager.fontManager.ttflist}
plt.rcParams["font.family"] = "Helvetica" if "Helvetica" in available else "Arial"
plt.rcParams["pdf.fonttype"] = 42
plt.rcParams["font.size"] = 8

templates = sio.loadmat(HERE / "data" / "task_templates.mat", squeeze_me=True, struct_as_record=False)["TEMPLATE"].template.TMP1000
trial_data = {}
for trial in TRIAL_TYPES:
    trial_struct = getattr(templates, trial)
    trial_data[trial] = np.hstack([np.asarray(getattr(trial_struct, s), dtype=float).ravel().reshape(-1, 1) for s in SIGNALS])
all_data = np.vstack([trial_data[t] for t in TRIAL_TYPES])
lengths = [trial_data[t].shape[0] for t in TRIAL_TYPES]


def split(result):
    out, start = {}, 0
    for trial, n in zip(TRIAL_TYPES, lengths):
        out[trial] = result[start:start + n, :]
        start += n
    return out


def end_on_ticks(ax, pts, xstep, ystep):
    """Axes start and end on labelled ticks: the tightest multiples of the step that enclose the data."""
    allpts = np.vstack(list(pts.values()))
    for axis, step, col in (("x", xstep, 0), ("y", ystep, 1)):
        lo = np.floor(allpts[:, col].min() / step) * step
        hi = np.ceil(allpts[:, col].max() / step) * step
        ticks = np.arange(lo, hi + step / 2, step)
        if axis == "x": ax.set_xlim(lo, hi); ax.set_xticks(ticks)
        else: ax.set_ylim(lo, hi); ax.set_yticks(ticks)


def overlap_matrix(points):
    """Number of 2-D histogram bins (NUM_BINS per axis) occupied by both tasks."""
    allpts = np.vstack(list(points.values()))
    rng = [[allpts[:, 0].min(), allpts[:, 0].max()], [allpts[:, 1].min(), allpts[:, 1].max()]]
    occ = {t: (np.histogram2d(p[:, 0], p[:, 1], bins=NUM_BINS, range=rng)[0] > 0) for t, p in points.items()}
    m = np.zeros((len(TRIAL_TYPES), len(TRIAL_TYPES)), dtype=int)
    for i, a in enumerate(TRIAL_TYPES):
        for j, b in enumerate(TRIAL_TYPES):
            m[i, j] = int(np.sum(occ[a] & occ[b]))
    return m


# ---------------------------------------------------------------- PCA
chi2, p = calculate_bartlett_sphericity(all_data)
kmo_each, kmo_all = calculate_kmo(all_data)   # factor_analyzer returns (per variable, overall)
print(f"Bartlett's test of sphericity: chi2 = {chi2:.2f}, p = {p:.3g}")
print(f"KMO overall = {float(kmo_all):.2f}; per muscle = " + ", ".join(f"{s} {float(k):.2f}" for s, k in zip(SIGNALS, np.ravel(kmo_each))))
pca = PCA(n_components=3)
pca_points = split(pca.fit_transform(all_data)[:, :2])
print(f"PCA explained variance (PC1, PC2, PC3): {np.round(pca.explained_variance_ratio_, 3)}")

# ---------------------------------------------------------------- UMAP
reducer = umap.UMAP(n_neighbors=15, min_dist=0.1, n_components=2, random_state=SEED)
umap_points = split(reducer.fit_transform(all_data))

m_pca, m_umap = overlap_matrix(pca_points), overlap_matrix(umap_points)
for title, m in [("PCA", m_pca), ("UMAP", m_umap)]:
    print(f"{title} shared bins: grasp-grip {m[0, 1]}, grasp-pronate {m[0, 2]}, grip-pronate {m[1, 2]} "
          f"(occupied bins: grasp {m[0, 0]}, grip {m[1, 1]}, pronate {m[2, 2]})")

# ---------------------------------------------------------------- Fig 10 (two panels)
fig, axes = plt.subplots(1, 2, figsize=(7.0, 2.4), dpi=300)
for ax, pts, xl, yl, label, note, note_xy, steps in [
        (axes[0], pca_points, "PC1, a.u.", "PC2, a.u.", "a.", "substantial overlap", (0.03, 0.96), (0.3, 0.2)),
        (axes[1], umap_points, "UMAP1, a.u.", "UMAP2, a.u.", "b.", "minimal overlap", (0.03, 0.96), (5, 15))]:
    for trial, lab, c in zip(TRIAL_TYPES, LABELS, COLORS):
        ax.plot(pts[trial][:, 0], pts[trial][:, 1], color=c, lw=1.3, alpha=0.9, label=lab, solid_capstyle="round")
    ax.set_xlabel(xl); ax.set_ylabel(yl)
    end_on_ticks(ax, pts, *steps)
    for sp in ("top", "right"):
        ax.spines[sp].set_visible(False)
    ax.tick_params(direction="out", length=3)
    ax.text(-0.22, 1.05, label, transform=ax.transAxes, fontsize=10, fontweight="bold", va="bottom")
    ax.text(note_xy[0], note_xy[1], note, transform=ax.transAxes, ha="left", va="top" if note_xy[1] > 0.5 else "bottom", fontsize=8, color="#333333")
axes[0].legend(frameon=False, fontsize=8, loc="lower left", handlelength=1.2)
fig.tight_layout(w_pad=2.5)
fig.savefig(OUT / "Fig10.pdf"); fig.savefig(OUT / "Fig10.png"); plt.close(fig)

fig, axs = plt.subplots(1, 2, figsize=(7, 3), dpi=300)
for ax, (title, m) in zip(axs, [("PCA", m_pca), ("UMAP", m_umap)]):
    ax.imshow(m, cmap="gray_r")
    ax.set_xticks(range(3)); ax.set_yticks(range(3)); ax.set_xticklabels(LABELS); ax.set_yticklabels(LABELS)
    for i in range(3):
        for j in range(3):
            ax.text(j, i, str(m[i, j]), ha="center", va="center", color="white" if m[i, j] > m.max() / 2 else "black")
    ax.set_title(f"{title}: shared occupancy bins")
fig.tight_layout(); fig.savefig(OUT / "fig10_overlap_matrices.pdf"); plt.close(fig)
print(f"figures written to {OUT}")
