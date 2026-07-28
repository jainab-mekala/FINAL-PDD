# ImplantGuard AI™
## Peri-implantitis Early Detection Surveillance System

> AI-powered longitudinal monitoring for dental implants — detecting early disease before irreversible bone loss occurs.

---

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Firebase Configuration](#firebase-configuration)
- [AI Prediction Engine](#ai-prediction-engine)
- [Data Models](#data-models)
- [Screens](#screens)
- [Security](#security)

---

## Overview

ImplantGuard AI™ is a clinical decision support system for dental professionals. It addresses a critical gap: **peri-implantitis is currently detected only after irreversible bone loss has occurred.** This app uses longitudinal patient data to predict early disease risk, enabling proactive intervention.

### Clinical Background
- Peri-implantitis affects 22% of implant patients over 10 years
- Early detection (mucositis stage) is fully reversible
- Advanced disease causes irreversible crestal bone loss
- Risk factors: smoking (3.6× risk), diabetes, poor oral hygiene, history of periodontal disease

---

## Features

### 🧠 AI Risk Prediction Engine
- Multi-factor weighted risk scoring model
- Evidence-based thresholds (Berglundh et al. 2018, EFP/AAP 2019)
- Longitudinal trend analysis (probing depth slope, bone loss rate)
- Feature contribution breakdown (explainable AI)
- Confidence scoring based on data completeness
- Estimated time-to-intervention calculation

### 👤 Patient Management
- Complete patient profiles with medical/risk history
- Systemic disease tracking (diabetes, osteoporosis, etc.)
- Smoking status and periodontal history
- Multi-implant support per patient

### 🦷 Implant Tracking
- Full implant specifications (brand, model, dimensions)
- FDI tooth position mapping
- Placement/loading date tracking
- Bone graft type recording
- Complication history

### 📊 Clinical Assessments
- 6-site probing depth measurements (MB, B, DB, ML, L, DL)
- Bleeding on probing (BOP)
- Suppuration detection
- Mobility grading (0–Grade 3)
- Plaque score recording
- Bone level change from baseline
- Patient-reported symptoms (VAS pain scale)
- X-ray image attachment

### 📈 Monitoring & Alerts
- Real-time risk status tracking
- Critical implant alert system
- Trend charts (probing depth over time)
- Risk distribution dashboard
- Fleet overview for all implants

### 🔔 Notifications
- Firebase Cloud Messaging (FCM) push alerts
- Local maintenance reminders
- Critical risk escalation alerts

### 📄 Reports
- Practice overview statistics
- Risk distribution pie chart
- High-priority implant list
- PDF export capability

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| Charts | fl_chart, syncfusion_flutter_charts |
| AI Engine | Custom weighted scoring + trend analysis |
| Future: TFLite | tflite_flutter (prepared) |
| Styling | Google Fonts (Rajdhani + Inter) |

---

## Project Structure

```
implantguard_ai/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # Router + Theme
│   ├── firebase_options.dart        # Firebase config (auto-generated)
│   │
│   ├── models/
│   │   ├── patient_model.dart       # Patient data model
│   │   ├── implant_model.dart       # Implant data model
│   │   ├── assessment_model.dart    # Clinical assessment model
│   │   └── prediction_model.dart   # AI prediction result model
│   │
│   ├── services/
│   │   ├── ai_prediction_service.dart  # Core AI engine
│   │   ├── auth_service.dart           # Firebase Auth
│   │   ├── patient_service.dart        # Firestore CRUD
│   │   └── notification_service.dart   # FCM + local notifications
│   │
│   ├── providers/
│   │   └── auth_provider.dart       # Riverpod providers
│   │
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── patients/
│   │   │   ├── patients_list_screen.dart
│   │   │   ├── patient_detail_screen.dart
│   │   │   └── add_patient_screen.dart
│   │   ├── implants/
│   │   │   ├── implant_detail_screen.dart
│   │   │   └── add_implant_screen.dart
│   │   ├── monitoring/
│   │   │   ├── monitoring_screen.dart
│   │   │   └── add_assessment_screen.dart
│   │   ├── ai/
│   │   │   └── ai_prediction_screen.dart
│   │   ├── reports/
│   │   │   └── reports_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   │
│   └── widgets/
│       ├── gradient_button.dart
│       ├── app_text_field.dart
│       ├── risk_gauge_widget.dart
│       ├── stat_card.dart
│       ├── implant_alert_card.dart
│       ├── patient_card.dart
│       ├── risk_chip.dart
│       └── recommendation_card.dart
│
├── firebase/
│   ├── firestore.rules              # Security rules
│   ├── firestore.indexes.json       # Composite indexes
│   └── storage.rules                # Storage security rules
│
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml
│
├── firebase.json                    # Firebase project config
├── pubspec.yaml                     # Dependencies
└── README.md
```

---

## Setup & Installation

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Firebase account
- Android Studio / Xcode

### Step 1: Clone and install dependencies
```bash
cd implantguard_ai
flutter pub get
```

### Step 2: Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named `implantguard-ai`
3. Enable the following services:
   - **Authentication** → Email/Password
   - **Cloud Firestore** → Start in production mode
   - **Firebase Storage**
   - **Firebase Cloud Messaging**

### Step 3: Configure FlutterFire
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (auto-generates firebase_options.dart)
flutterfire configure --project=implantguard-ai
```

This replaces `lib/firebase_options.dart` with your actual credentials.

### Step 4: Deploy Firebase Rules
```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Deploy Firestore rules and indexes
firebase deploy --only firestore
firebase deploy --only storage
```

### Step 5: Run the app
```bash
# Android
flutter run -d android

# iOS (requires Mac + Xcode)
flutter run -d ios

# Debug mode with verbose logging
flutter run --verbose
```

---

## Firebase Configuration

### Firestore Collections Schema

#### `doctors/{uid}`
```json
{
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "dr.smith@clinic.com",
  "clinicName": "SmileCare Dental",
  "specialty": "Periodontist",
  "licenseNumber": "DEN-12345",
  "createdAt": "Timestamp"
}
```

#### `patients/{id}`
```json
{
  "doctorId": "uid",
  "firstName": "John",
  "lastName": "Doe",
  "dateOfBirth": "Timestamp",
  "gender": "male",
  "smokingStatus": "currentSmoker",
  "medicalConditions": ["Diabetes (Type 2)"],
  "hasPeriodontalHistory": true,
  "implantIds": ["implant_id_1"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

#### `implants/{id}`
```json
{
  "patientId": "patient_id",
  "doctorId": "uid",
  "brand": "Nobel Biocare",
  "model": "NobelActive",
  "diameter": 3.5,
  "length": 10.0,
  "position": { "arch": "upper", "side": "right", "toothNumber": 16 },
  "placementDate": "Timestamp",
  "currentStatus": "atRisk",
  "riskScore": 0.68,
  "assessmentIds": ["assessment_id_1"],
  "updatedAt": "Timestamp"
}
```

#### `assessments/{id}`
```json
{
  "implantId": "implant_id",
  "patientId": "patient_id",
  "doctorId": "uid",
  "assessmentDate": "Timestamp",
  "probingDepths": {
    "mesialBuccal": 4.5,
    "buccal": 3.0,
    "distalBuccal": 5.0,
    "mesialLingual": 3.5,
    "lingual": 3.0,
    "distalLingual": 4.0
  },
  "boneLevelChange": 1.5,
  "bleedingOnProbing": "present",
  "suppuration": "absent",
  "mobility": "none",
  "mucositisPresent": true,
  "predictedRiskScore": 0.68,
  "riskCategory": "High Risk",
  "aiRecommendations": ["Immediate Clinical Intervention"],
  "createdAt": "Timestamp"
}
```

---

## AI Prediction Engine

### Algorithm Overview

The `AIPredictionService` uses a **multi-factor weighted scoring model**:

```
Risk Score = Σ (feature_value × feature_weight) × trend_multiplier
```

### Feature Weights (Evidence-Based)

| Feature | Weight | Clinical Basis |
|---------|--------|----------------|
| Bone Level Change | 22% | Primary diagnostic criterion (Berglundh 2018) |
| Max Probing Depth | 20% | ≥6mm = peri-implantitis threshold |
| Suppuration | 14% | Strong indicator of active infection |
| Bleeding on Probing | 12% | Inflammatory marker |
| Worsening Trend | 6% | Longitudinal deterioration |
| Mobility | 10% | Late-stage indicator |
| Smoking Status | 4% | 3.6× risk multiplier |
| Diabetes | 4% | Impairs wound healing |
| Mucositis Present | 5% | Precursor stage |
| Plaque Score | 3% | Modifiable risk factor |

### Risk Classification

| Score | Level | Action |
|-------|-------|--------|
| 0–24% | 🟢 Low | 6-month routine recall |
| 25–49% | 🟡 Moderate | 3-month enhanced recall + debridement |
| 50–74% | 🟠 High | Immediate intervention + antibiotics |
| 75–100% | 🔴 Critical | Urgent surgical referral |

### Trend Analysis
- Computes linear regression slope on last 3–5 assessments
- Worsening trend → 25% score amplification
- Improving trend → 15% score reduction

### Evidence Sources
- Berglundh T, et al. (2018). *A systematic review of the incidence and the prevalence of peri-implant diseases.* J Clin Periodontol.
- Renvert S, et al. (2019). *Peri-implant health, peri-implant mucositis, and peri-implantitis.* J Clin Periodontol.
- EFP/AAP World Workshop 2019 Classification of Periodontal and Peri-Implant Diseases.

---

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/splash` | Animated loading + auth redirect |
| Login | `/auth/login` | Email/password sign in |
| Register | `/auth/register` | Doctor account creation |
| Dashboard | `/dashboard` | Overview, stats, alerts |
| Patients | `/patients` | Patient list with search |
| Patient Detail | `/patients/:id` | Profile + implant list |
| Add Patient | `/patients/add` | Full patient intake form |
| Implant Detail | `/implants/:id` | Specs + trend chart + history |
| Add Implant | `/implants/add` | Implant registration form |
| Monitoring | `/monitoring` | All implants sorted by risk |
| Add Assessment | `/monitoring/add/:id` | 3-tab clinical assessment form |
| AI Prediction | `/ai-prediction/:id` | Risk analysis + recommendations |
| Reports | `/reports` | Practice analytics + charts |
| Settings | `/settings` | Profile + preferences |

---

## Security

- **Authentication**: Firebase Auth with email/password
- **Authorization**: Firestore rules enforce `doctorId == auth.uid` on all reads/writes
- **Data Isolation**: Each doctor can only access their own patients/implants/assessments
- **Storage Security**: X-ray images restricted by `doctorId` path
- **HIPAA Considerations**:
  - All data stored in Firebase (SOC 2 Type II compliant)
  - No patient data logged client-side
  - Password reset via secure email link
  - Biometric authentication support (local_auth package)
  - HTTPS enforced for all API calls

---

## Future Enhancements

- [ ] TFLite on-device ML model (trained on clinical datasets)
- [ ] X-ray AI analysis (bone level detection from radiographs)
- [ ] DICOM integration for dental imaging
- [ ] Multi-doctor practice support with role-based access
- [ ] Patient portal (read-only patient-facing app)
- [ ] HL7/FHIR integration for EMR connectivity
- [ ] Longitudinal outcome tracking (treatment success rates)
- [ ] Automated recall scheduling via email/SMS

---

## License

© 2024 ImplantGuard AI™. All rights reserved.

This software is intended for use by licensed dental professionals as a clinical decision support tool. It does not replace professional clinical judgment, radiographic evaluation, or established diagnostic protocols.

---

## Support

For technical support or clinical questions, contact: support@implantguard.ai
