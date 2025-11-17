#!/usr/bin/env python3

import sys
import joblib
import numpy as np
from scipy.stats import skew, kurtosis, entropy

#model_path = "/home/ucfbsbh/usr/hcp_fe_train_density/density_classifier_fe_hcp.pkl"


model_path = "/home/ucfbsbh/usr/pcfc/ml/models/density_classifier.pkl"

def compute_features(filepath):
    try:
        data = np.loadtxt(filepath)
        if data.shape[0] < 50:
            return None
        counts = data[:, 1]

        mean_val = np.mean(counts)
        std_val = np.std(counts)
        max_val = np.max(counts)
        min_val = np.min(counts)
        skew_val = skew(counts)
        kurt_val = kurtosis(counts)

        zero_thresh = 5
        zero_ratio = np.sum(counts < zero_thresh) / len(counts)
        high_ratio = np.sum(counts > (mean_val + std_val)) / len(counts)
        low_ratio = np.sum(counts < (mean_val - std_val)) / len(counts)

        prob = counts / np.sum(counts)
        ent = entropy(prob + 1e-12)

        return [mean_val, std_val, max_val, min_val, skew_val, kurt_val,
                zero_ratio, high_ratio, low_ratio, ent]
    except Exception as e:
        print(f"Error reading file {filepath}: {e}", file=sys.stderr)
        return None

def main():
    if len(sys.argv) < 2:
        print("Usage: classify_density.py density_3500K.12.dat_Solid-only.dat")
        sys.exit(1)

    infile = sys.argv[1]
    features = compute_features(infile)
    if features is None:
        print("Crashed")
        return

    clf = joblib.load(model_path)
    prediction = clf.predict([features])[0]
    print(prediction)

if __name__ == "__main__":
    main()

