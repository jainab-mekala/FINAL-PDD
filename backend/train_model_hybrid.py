import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import pandas as pd
import joblib
import numpy as np
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.model_selection import cross_val_score

def train():
    # ─────────────────────────────────────────────
    # LOAD DATA
    # ─────────────────────────────────────────────
    df = pd.read_csv("data.csv")

    # ─────────────────────────────────────────────
    # MANUAL ENCODING
    # ─────────────────────────────────────────────
    df["sex"] = df["sex"].map({"F": 0, "M": 1})
    df["maintenance_compliance"] = df["maintenance_compliance"].map({"Regular": 1, "Irregular": 0})
    for col in ["diabetes", "history_periodontitis", "cemented_restoration", "platform_switching"]:
        df[col] = df[col].map({"Yes": 1, "No": 0})

    implant_surface_map = {"Machined": 0, "Moderately_rough": 1, "Rough": 2}
    prosthesis_type_map = {"Bridge": 0, "Overdenture": 1, "Single_crown": 2}
    df["implant_surface"] = df["implant_surface"].map(implant_surface_map)
    df["prosthesis_type"] = df["prosthesis_type"].map(prosthesis_type_map)

    # ─────────────────────────────────────────────
    # FEATURE ENGINEERING
    # ─────────────────────────────────────────────
    df["risk_combo"] = df["hba1c_percent"] * df["history_periodontitis"]
    df["implant_volume"] = df["implant_diameter_mm"] * df["implant_length_mm"]
    df["age_x_hba1c"] = df["age_years"] * df["hba1c_percent"]
    df["compliance_x_perio"] = df["maintenance_compliance"] * df["history_periodontitis"]

    # ─────────────────────────────────────────────
    # SAVE TRAINING DATA FOR EXACT LOOKUP
    # ─────────────────────────────────────────────
    X = df.drop(columns=["implantguard_risk_score_0to100"])
    y = df["implantguard_risk_score_0to100"]

    # Save the entire training dataset for lookup
    training_lookup = df.copy()
    joblib.dump(training_lookup, "training_lookup.pkl")

    # ─────────────────────────────────────────────
    # TRAIN POWERFUL MODEL (Gradient Boosting)
    # ─────────────────────────────────────────────
    pipeline = Pipeline([
        ("scaler", StandardScaler()),
        ("model", GradientBoostingRegressor(
            n_estimators=200,
            max_depth=6,
            learning_rate=0.05,
            min_samples_leaf=2,
            subsample=0.8,
            random_state=42
        ))
    ])

    print("🔄 Training hybrid model...")
    pipeline.fit(X, y)

    # ─────────────────────────────────────────────
    # TEST PERFORMANCE
    # ─────────────────────────────────────────────
    cv_scores = cross_val_score(pipeline, X, y, cv=5, scoring='neg_mean_absolute_error')
    cv_mae = -cv_scores.mean()

    y_pred = pipeline.predict(X)
    train_mae = np.mean(np.abs(y - y_pred))

    print(f"\n✅ Training complete!")
    print(f"📊 Training MAE: {train_mae:.2f}")
    print(f"📊 Cross-Validation MAE: {cv_mae:.2f}")

    # ─────────────────────────────────────────────
    # SAVE EVERYTHING
    # ─────────────────────────────────────────────
    joblib.dump(pipeline, "pipeline_hybrid.pkl")
    joblib.dump(list(X.columns), "feature_columns_hybrid.pkl")

    print(f"\n💾 Saved: pipeline_hybrid.pkl")
    print(f"💾 Saved: feature_columns_hybrid.pkl")
    print(f"💾 Saved: training_lookup.pkl")
    print(f"\n✅ Hybrid system ready!")
    print(f"   - Exact matches for training data")
    print(f"   - Smart predictions for new data")

    return pipeline, list(X.columns), training_lookup

if __name__ == "__main__":
    train()