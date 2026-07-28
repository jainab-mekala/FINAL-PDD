import urllib.request
import json
import urllib.error

url = 'https://api-implant-developed-1.onrender.com/predict'
data = {
    "age_years": 58.0,
    "sex": "M",
    "diabetes": "Yes",
    "hba1c_percent": 9.7,
    "history_periodontitis": "No",
    "maintenance_compliance": "Regular",
    "implant_surface": "Moderately_rough",
    "implant_diameter_mm": 3.7,
    "implant_length_mm": 14.0,
    "prosthesis_type": "Single_crown",
    "cemented_restoration": "Yes",
    "platform_switching": "Yes",
    "time_in_function_months": 12.0
}

req = urllib.request.Request(
    url, 
    data=json.dumps(data).encode('utf-8'), 
    headers={'Content-Type': 'application/json'}
)

try:
    with urllib.request.urlopen(req) as response:
        print("Status:", response.status)
        print(response.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print("HTTP Error:", e.code)
    print(e.read().decode('utf-8'))
