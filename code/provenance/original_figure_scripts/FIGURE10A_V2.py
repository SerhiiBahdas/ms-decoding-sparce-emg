#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Dec 11 23:51:54 2024

@author: seba
"""

import scipy.io as sio
import numpy as np
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
from factor_analyzer import calculate_bartlett_sphericity, calculate_kmo

# Load the MAT file
mat_data = sio.loadmat('/Users/seba/Library/CloudStorage/GoogleDrive-sb0220@mix.wvu.edu/Shared drives/DECODER SB-SY/NOVEMBER DEV/FIGURES/FIGURE_UMAP.mat')  # Replace with the correct file path

# Define trial types and signals
trial_types = ['GRASP25', 'GRIP25', 'PRONATE25']
signals = ["DELT_A", "DELT_M", "DELT_P", "BIC_SH", "BIC_LO", "TRI_LAT", "TRI_LO"]

# Extract and flatten the signals for each trial type
trial_data = {}
for trial in trial_types:
    trial_struct = mat_data['tmp'][trial][0, 0]  # Access the structure for the trial type
    # Extract and flatten each signal
    trial_signals = np.hstack([
        np.array(trial_struct[signal][0, 0]).flatten().reshape(-1, 1)
        for signal in signals
    ])
    trial_data[trial] = trial_signals

# Combine the data for PCA
all_data = np.vstack([trial_data[trial] for trial in trial_types])

# Perform Bartlett's Test of Sphericity
bartlett_chi_square_value, bartlett_p_value = calculate_bartlett_sphericity(all_data)

# Perform Kaiser-Meyer-Olkin (KMO) Measure
kmo_all, kmo_individual = calculate_kmo(all_data)

# Display results of Bartlett's test and KMO
print(f"Bartlett's Test Chi-Square Value: {bartlett_chi_square_value}")
print(f"Bartlett's Test p-value: {bartlett_p_value}")
print(f"KMO Measure (Overall): {kmo_all}")

# Perform PCA
pca = PCA(n_components=3)
pca_result = pca.fit_transform(all_data)

# Split PCA-transformed data back by trial type
pca_trial_data = {}
start_idx = 0
for trial in trial_types:
    trial_len = trial_data[trial].shape[0]
    pca_trial_data[trial] = pca_result[start_idx:start_idx + trial_len, :]
    start_idx += trial_len

# -------------------- PCA Plot --------------------
# Plot PCA results (PC1 vs PC2)
fig, ax = plt.subplots(figsize=(4, 3), dpi=600)  # Adjust figure size and resolution for publication

colors = ['r', 'g', 'b']
for i, trial in enumerate(trial_types):
    data = pca_trial_data[trial]
    ax.plot(data[:, 0], data[:, 1], label=trial, alpha=0.7, color=colors[i])

# Set axis labels (font size 10)
ax.set_xlabel("PC1", fontsize=10)
ax.set_ylabel("PC2", fontsize=10)

# Adjust font size for tick labels
ax.tick_params(axis='both', which='major', labelsize=8)

# Add legend
ax.legend(fontsize=8)

# Remove title (per request)
# Save as SVG for Adobe Illustrator editing
plt.savefig('pca_plot_2D.svg', format='svg', bbox_inches='tight')
# Save as PDF
plt.savefig('pca_plot_2D.pdf', format='pdf', bbox_inches='tight')
plt.show()

#----------------------------------------------------
# 8. Overlap Calculation for PCA (PC1 vs PC2)
#----------------------------------------------------
print("\n--- Overlap Calculation in PCA Space (2D) ---")

num_bins = 50  # same binning approach as with UMAP
# Collect min/max across all data for the first two principal components
pca_2d = pca_result[:, :2]  # just PC1 and PC2
min_x = np.min(pca_2d[:, 0])
max_x = np.max(pca_2d[:, 0])
min_y = np.min(pca_2d[:, 1])
max_y = np.max(pca_2d[:, 1])

# Create histograms for each trial type in PCA 2D space
histograms_pca = {}
for trial in trial_types:
    data_2d = pca_trial_data[trial][:, :2]
    H, xedges, yedges = np.histogram2d(
        data_2d[:, 0],
        data_2d[:, 1],
        bins=num_bins,
        range=[[min_x, max_x], [min_y, max_y]]
    )
    histograms_pca[trial] = H

# Convert each histogram to a binary occupancy map
bin_occ_pca = {}
for trial in trial_types:
    bin_occ_pca[trial] = (histograms_pca[trial] > 0).astype(int)

# Calculate overlaps
conf_mat_pca = np.zeros((len(trial_types), len(trial_types)), dtype=int)
bin_occ_list_pca = [bin_occ_pca[t] for t in trial_types]
for i in range(len(trial_types)):
    for j in range(len(trial_types)):
        conf_mat_pca[i, j] = np.sum(bin_occ_list_pca[i] & bin_occ_list_pca[j])

# Print the pairwise intersection results (bins overlapped)
print(f"TRIAL 1 INTERSECTED W TRIAL 2 (PCA): {conf_mat_pca[0, 1]} TIMES")
print(f"TRIAL 1 INTERSECTED W TRIAL 3 (PCA): {conf_mat_pca[0, 2]} TIMES")
print(f"TRIAL 2 INTERSECTED W TRIAL 3 (PCA): {conf_mat_pca[1, 2]} TIMES")

# -------------------- Confusion Matrix Plot (Grayscale) --------------------
fig2, ax2 = plt.subplots(figsize=(4, 3), dpi=600)
cax = ax2.imshow(conf_mat_pca, interpolation='nearest', cmap='gray')
fig2.colorbar(cax, ax=ax2, label='# of Bins Overlapped (PCA)')

# Set up ticks and labels
ax2.set_xticks(range(len(trial_types)))
ax2.set_yticks(range(len(trial_types)))
ax2.set_xticklabels(trial_types, fontsize=8)
ax2.set_yticklabels(trial_types, fontsize=8)
ax2.set_xlabel('Trial Type (column)', fontsize=10)
ax2.set_ylabel('Trial Type (row)', fontsize=10)

# Optional: numeric labels in each cell
for i in range(len(trial_types)):
    for j in range(len(trial_types)):
        ax2.text(j, i, str(conf_mat_pca[i, j]),
                 ha='center', va='center',
                 color='white' if conf_mat_pca[i, j] > conf_mat_pca.max()/2 else 'black')

plt.tight_layout()
# Save confusion matrix as PDF
plt.savefig('pca_confusion_matrix.pdf', format='pdf', bbox_inches='tight')
plt.show()
