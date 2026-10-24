#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 21 15:43:19 2025

@author: seba
"""

import numpy as np
import matplotlib.pyplot as plt
import scipy.io as sio
import umap

#-----------------------------------------------
# 1. Load and prepare the data (your existing code)
#-----------------------------------------------
mat_data = sio.loadmat('/Users/seba/Library/CloudStorage/GoogleDrive-sb0220@mix.wvu.edu/Shared drives/DECODER SB-SY/NOVEMBER DEV/FIGURES/FIGURE_UMAP.mat')  # Replace with correct path

trial_types = ['GRASP25', 'GRIP25', 'PRONATE25']
signals = ["DELT_A", "DELT_M", "DELT_P", "BIC_SH", "BIC_LO", "TRI_LAT", "TRI_LO"]

# Extract and flatten the signals for each trial type
trial_data = {}
for trial in trial_types:
    trial_struct = mat_data['tmp'][trial][0, 0]
    trial_signals = np.hstack([
        np.array(trial_struct[signal][0, 0]).flatten().reshape(-1, 1) 
        for signal in signals
    ])
    trial_data[trial] = trial_signals

# Combine the data for UMAP
all_data = np.vstack([trial_data[trial] for trial in trial_types])

# Perform UMAP (2D)
umap_model = umap.UMAP(n_neighbors=15, min_dist=0.1, n_components=2, random_state=42)
umap_result = umap_model.fit_transform(all_data)

# Split UMAP-transformed data back by trial type
umap_trial_data = {}
start_idx = 0
for trial in trial_types:
    trial_len = trial_data[trial].shape[0]
    umap_trial_data[trial] = umap_result[start_idx:start_idx + trial_len, :]
    start_idx += trial_len

#-----------------------------------------------
# (New) Plot the UMAP embedding for each trial
#-----------------------------------------------
fig_umap, ax_umap = plt.subplots(figsize=(5, 4), dpi=120)
colors = ['r', 'g', 'b']
for i, trial in enumerate(trial_types):
    ax_umap.scatter(
        umap_trial_data[trial][:, 0],
        umap_trial_data[trial][:, 1],
        s=10,
        alpha=0.6,
        color=colors[i],
        label=trial
    )
ax_umap.set_xlabel('UMAP-1', fontsize=10)
ax_umap.set_ylabel('UMAP-2', fontsize=10)
ax_umap.legend(fontsize=8)
ax_umap.set_title('UMAP Embedding', fontsize=12)
plt.tight_layout()
# Save UMAP plot as PDF
plt.savefig('umap_plot.pdf', format='pdf', bbox_inches='tight')
plt.show()

#-----------------------------------------------------------
# 2. Create a 2D histogram (binned space) for each trial type
#-----------------------------------------------------------
num_bins = 50  # You can adjust this

# Collect min/max across all data for a common bin range
min_x = np.min(umap_result[:, 0])
max_x = np.max(umap_result[:, 0])
min_y = np.min(umap_result[:, 1])
max_y = np.max(umap_result[:, 1])

histograms = {}
edges = None

for trial in trial_types:
    x_data = umap_trial_data[trial][:, 0]
    y_data = umap_trial_data[trial][:, 1]
    H, xedges, yedges = np.histogram2d(
        x_data,
        y_data,
        bins=num_bins,
        range=[[min_x, max_x], [min_y, max_y]]
    )
    histograms[trial] = H
    if edges is None:
        edges = (xedges, yedges)

#------------------------------------------------------------
# 3. Convert each histogram to a binary occupancy map (0 or 1)
#------------------------------------------------------------
bin_occ = {}
for trial in trial_types:
    # 1 if bin has at least one point from that trial, else 0
    bin_occ[trial] = (histograms[trial] > 0).astype(int)

bin_occ_list = [bin_occ[t] for t in trial_types]

#------------------------------------------------------------
# 4. Construct the "confusion matrix" of pairwise overlaps
#------------------------------------------------------------
num_trials = len(trial_types)
conf_mat = np.zeros((num_trials, num_trials), dtype=int)

for i in range(num_trials):
    for j in range(num_trials):
        # Number of bins occupied by both i and j
        conf_mat[i, j] = np.sum(bin_occ_list[i] & bin_occ_list[j])

#------------------------------------------------------------
# 5. Plot the matrix as a heatmap (Grayscale)
#------------------------------------------------------------
fig, ax = plt.subplots(figsize=(5, 4), dpi=120)

# Show the confusion matrix in grayscale
cax = ax.imshow(conf_mat, interpolation='nearest', cmap='gray')
fig.colorbar(cax, ax=ax, label='# of Bins Overlapped')

# Set up ticks and labels
ax.set_xticks(range(num_trials))
ax.set_yticks(range(num_trials))
ax.set_xticklabels(trial_types)
ax.set_yticklabels(trial_types)
ax.set_ylabel('Trial Type (row)', fontsize=10)
ax.set_xlabel('Trial Type (column)', fontsize=10)
plt.title('Confusion Matrix (UMAP Bin Overlaps)', fontsize=12)

# Optional: Add numeric labels in each cell
for i in range(num_trials):
    for j in range(num_trials):
        ax.text(j, i, str(conf_mat[i, j]),
                ha='center', va='center',
                color='white' if conf_mat[i, j] > conf_mat.max()/2 else 'black')

plt.tight_layout()
# Save confusion matrix as PDF
plt.savefig('umap_confusion_matrix.pdf', format='pdf', bbox_inches='tight')
plt.show()

#-----------------------------------
# 6. Interpreting the matrix
#-----------------------------------
# - conf_mat[i, i] is the # of bins that trial i occupies
# - conf_mat[i, j] (i != j) is the # of bins shared by trials i and j.

#-----------------------------------
# 7. Print pairwise intersection results
#-----------------------------------
print(f"TRIAL 1 INTERSECTED W TRIAL 2: {conf_mat[0, 1]} TIMES")
print(f"TRIAL 1 INTERSECTED W TRIAL 3: {conf_mat[0, 2]} TIMES")
print(f"TRIAL 2 INTERSECTED W TRIAL 3: {conf_mat[1, 2]} TIMES")
