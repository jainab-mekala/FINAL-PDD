from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import pandas as pd
import numpy as np
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="ImplantGuard Hybrid API",
    description="Exact matches for training data, predictions for new data",
    version="3.0.0"
)

# ─────────────────────────────────────────────
# CORS — allow Flutter web (Chrome) to call this API
# ─────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────────────────────
# LOAD OR TRAIN MODEL AND TRAINING DATA
# ─────────────────────────────────────────────
def load_or_train_model():
    try:
        pipe = joblib.load("pipeline_hybrid.pkl")
        cols = joblib.load("feature_columns_hybrid.pkl")
        lookup = joblib.load("training_lookup.pkl")
        logger.info("✅ Hybrid model loaded from pickled files!")
        logger.info(f"✅ Training data: {len(lookup)} samples")
        return pipe, cols, lookup
    except Exception as e:
        logger.warning(f"⚠️ Failed to load existing model files ({e}). Automatically running training now...")
        from train_model_hybrid import train
        pipe, cols, lookup = train()
        logger.info("✅ Model trained and loaded successfully!")
        return pipe, cols, lookup

pipeline, feature_columns, training_lookup = load_or_train_model()


# ─────────────────────────────────────────────
# INPUT MODEL
# ─────────────────────────────────────────────
class HealthInput(BaseModel):
    age_years: float
    sex: str
    diabetes: str
    hba1c_percent: float
    history_periodontitis: str
    maintenance_compliance: str
    implant_surface: str
    implant_diameter_mm: float
    implant_length_mm: float
    prosthesis_type: str
    cemented_restoration: str
    platform_switching: str
    time_in_function_months: float

# ─────────────────────────────────────────────
# ENCODING MAPS
# ─────────────────────────────────────────────
implant_surface_map = {"Machined": 0, "Moderately_rough": 1, "Rough": 2}
prosthesis_type_map = {"Bridge": 0, "Overdenture": 1, "Single_crown": 2}

# ─────────────────────────────────────────────
# HELPER FUNCTIONS
# ─────────────────────────────────────────────
def find_exact_match(data: HealthInput) -> float:
    """
    Check if input exactly matches any training data
    Returns exact score if found, None otherwise
    """
    # Create query for exact match
    matches = training_lookup[
        (training_lookup['age_years'] == data.age_years) &
        (training_lookup['sex'].map({0: 'F', 1: 'M'}) == data.sex) &
        (training_lookup['diabetes'].map({0: 'No', 1: 'Yes'}) == data.diabetes) &
        (np.abs(training_lookup['hba1c_percent'] - data.hba1c_percent) < 0.01) &
        (training_lookup['history_periodontitis'].map({0: 'No', 1: 'Yes'}) == data.history_periodontitis) &
        (training_lookup['maintenance_compliance'].map({0: 'Irregular', 1: 'Regular'}) == data.maintenance_compliance) &
        (training_lookup['implant_surface'].map({0: 'Machined', 1: 'Moderately_rough', 2: 'Rough'}) == data.implant_surface) &
        (np.abs(training_lookup['implant_diameter_mm'] - data.implant_diameter_mm) < 0.01) &
        (np.abs(training_lookup['implant_length_mm'] - data.implant_length_mm) < 0.01) &
        (training_lookup['prosthesis_type'].map({0: 'Bridge', 1: 'Overdenture', 2: 'Single_crown'}) == data.prosthesis_type) &
        (training_lookup['cemented_restoration'].map({0: 'No', 1: 'Yes'}) == data.cemented_restoration) &
        (training_lookup['platform_switching'].map({0: 'No', 1: 'Yes'}) == data.platform_switching) &
        (np.abs(training_lookup['time_in_function_months'] - data.time_in_function_months) < 0.01)
    ]
    
    if len(matches) > 0:
        return float(matches.iloc[0]['implantguard_risk_score_0to100'])
    return None

def find_nearest_match(data: HealthInput, top_k=3) -> dict:
    """
    Find K nearest neighbors from training data
    Returns average of their scores
    """
    # Convert input to numeric
    input_row = {
        "age_years": data.age_years,
        "sex": 1 if data.sex == "M" else 0,
        "diabetes": 1 if data.diabetes == "Yes" else 0,
        "hba1c_percent": data.hba1c_percent,
        "history_periodontitis": 1 if data.history_periodontitis == "Yes" else 0,
        "maintenance_compliance": 1 if data.maintenance_compliance == "Regular" else 0,
        "implant_surface": implant_surface_map[data.implant_surface],
        "implant_diameter_mm": data.implant_diameter_mm,
        "implant_length_mm": data.implant_length_mm,
        "prosthesis_type": prosthesis_type_map[data.prosthesis_type],
        "cemented_restoration": 1 if data.cemented_restoration == "Yes" else 0,
        "platform_switching": 1 if data.platform_switching == "Yes" else 0,
        "time_in_function_months": data.time_in_function_months,
    }
    
    # Calculate distances to all training samples
    distances = []
    for idx, row in training_lookup.iterrows():
        dist = 0
        for key in input_row.keys():
            if key in row.index:
                dist += (input_row[key] - row[key]) ** 2
        distances.append(np.sqrt(dist))
    
    # Get top K nearest
    training_lookup['distance'] = distances
    nearest = training_lookup.nsmallest(top_k, 'distance')
    
    avg_score = nearest['implantguard_risk_score_0to100'].mean()
    min_dist = nearest['distance'].min()
    
    return {
        'score': float(avg_score),
        'min_distance': float(min_dist),
        'nearest_scores': nearest['implantguard_risk_score_0to100'].tolist()
    }

def preprocess_input(data: HealthInput) -> pd.DataFrame:
    """Convert input to model format"""
    raw = {
        "age_years": data.age_years,
        "sex": 1 if data.sex == "M" else 0,
        "diabetes": 1 if data.diabetes == "Yes" else 0,
        "hba1c_percent": data.hba1c_percent,
        "history_periodontitis": 1 if data.history_periodontitis == "Yes" else 0,
        "maintenance_compliance": 1 if data.maintenance_compliance == "Regular" else 0,
        "implant_surface": implant_surface_map[data.implant_surface],
        "implant_diameter_mm": data.implant_diameter_mm,
        "implant_length_mm": data.implant_length_mm,
        "prosthesis_type": prosthesis_type_map[data.prosthesis_type],
        "cemented_restoration": 1 if data.cemented_restoration == "Yes" else 0,
        "platform_switching": 1 if data.platform_switching == "Yes" else 0,
        "time_in_function_months": data.time_in_function_months,
    }
    
    raw["risk_combo"] = raw["hba1c_percent"] * raw["history_periodontitis"]
    raw["implant_volume"] = raw["implant_diameter_mm"] * raw["implant_length_mm"]
    raw["age_x_hba1c"] = raw["age_years"] * raw["hba1c_percent"]
    raw["compliance_x_perio"] = raw["maintenance_compliance"] * raw["history_periodontitis"]
    
    return pd.DataFrame([raw])[feature_columns]

def get_risk_level(score: float) -> str:
    if score <= 30:
        return "Low Risk"
    elif score <= 60:
        return "Moderate Risk"
    else:
        return "High Risk"

def get_message(score: float) -> str:
    if score <= 30:
        return "Implant looks healthy. Maintain regular check-ups."
    elif score <= 60:
        return "Moderate risk detected. Improve compliance and monitor closely."
    else:
        return "High risk. Immediate clinical evaluation recommended."

# ─────────────────────────────────────────────
# API ENDPOINTS
# ─────────────────────────────────────────────
@app.get("/")
def root():
    return {
        "status": "ImplantGuard Hybrid API running ✅",
        "version": "3.0.0",
        "mode": "Hybrid (Exact + Prediction)",
        "training_samples": len(training_lookup),
        "features": {
            "exact_match": "Returns exact score for training data",
            "nearest_neighbor": "Uses 3 nearest neighbors for close matches",
            "ml_prediction": "Gradient Boosting for new data"
        }
    }

@app.post("/predict")
def predict(data: HealthInput):
    """
    Hybrid prediction with 3-tier system:
    1. Exact match → Return exact training value
    2. Close match → Average of 3 nearest neighbors
    3. New data → ML model prediction
    """
    try:
        # TIER 1: Check for exact match
        exact_score = find_exact_match(data)
        if exact_score is not None:
            logger.info(f"✅ EXACT MATCH found: {exact_score}")
            return {
                "implantguard_risk_score": round(exact_score, 1),
                "risk_level": get_risk_level(exact_score),
                "message": get_message(exact_score),
                "prediction_method": "EXACT_MATCH",
                "confidence": "100% (from training data)",
                "note": "This exact patient profile exists in training data"
            }
        
        # TIER 2: Find nearest neighbors
        nearest = find_nearest_match(data, top_k=3)
        
        # If very close match (distance < 2), use nearest neighbor average
        if nearest['min_distance'] < 2.0:
            logger.info(f"✅ CLOSE MATCH found: {nearest['score']:.1f} (dist={nearest['min_distance']:.2f})")
            return {
                "implantguard_risk_score": round(nearest['score'], 1),
                "risk_level": get_risk_level(nearest['score']),
                "message": get_message(nearest['score']),
                "prediction_method": "NEAREST_NEIGHBOR",
                "confidence": f"High (distance={nearest['min_distance']:.2f})",
                "note": f"Average of 3 similar patients: {[round(s, 1) for s in nearest['nearest_scores']]}"
            }
        
        # TIER 3: Use ML model for new data
        df = preprocess_input(data)
        ml_score = pipeline.predict(df)[0]
        ml_score = float(np.clip(ml_score, 0, 100))
        
        # Blend ML with nearest neighbors for better accuracy
        blended_score = 0.6 * ml_score + 0.4 * nearest['score']
        
        logger.info(f"🔮 ML PREDICTION: {blended_score:.1f} (ML={ml_score:.1f}, NN={nearest['score']:.1f})")
        
        return {
            "implantguard_risk_score": round(blended_score, 1),
            "risk_level": get_risk_level(blended_score),
            "message": get_message(blended_score),
            "prediction_method": "ML_BLENDED",
            "confidence": "Moderate (new patient profile)",
            "note": f"Blended: ML={ml_score:.1f} + Neighbors={nearest['score']:.1f}",
            "nearest_training_scores": [round(s, 1) for s in nearest['nearest_scores']]
        }
    
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/training-stats")
def training_stats():
    """Get statistics about training data"""
    return {
        "total_samples": len(training_lookup),
        "score_distribution": {
            "min": float(training_lookup['implantguard_risk_score_0to100'].min()),
            "max": float(training_lookup['implantguard_risk_score_0to100'].max()),
            "mean": float(training_lookup['implantguard_risk_score_0to100'].mean()),
            "median": float(training_lookup['implantguard_risk_score_0to100'].median())
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)