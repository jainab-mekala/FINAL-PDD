import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  // Production Render backend URL
  static const String baseUrl = "https://api-implant-developed-1.onrender.com";

  Future<Map<String, dynamic>> predictRiskScore({
    required double ageYears,
    required int sex, // 0=Female, 1=Male
    required int diabetes, // 0=No, 1=Yes
    required double hba1cPercent,
    required int historyPeriodontitis, // 0=No, 1=Yes
    required int maintenanceCompliance, // 1=Regular, 0=Irregular
    required int implantSurface, // 0=Machined, 1=Moderately_rough, 2=Rough
    required double implantDiameterMm,
    required double implantLengthMm,
    required int prosthesisType, // 0=Bridge, 1=Overdenture, 2=Single_crown
    required int cementedRestoration, // 0=No, 1=Yes
    required int platformSwitching, // 0=No, 1=Yes
    required double timeInFunctionMonths,
  }) async {
    final url = Uri.parse("$baseUrl/predict");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age_years": ageYears,
          "sex": sex == 1 ? "M" : "F",
          "diabetes": diabetes == 1 ? "Yes" : "No",
          "hba1c_percent": hba1cPercent,
          "history_periodontitis": historyPeriodontitis == 1 ? "Yes" : "No",
          "maintenance_compliance": maintenanceCompliance == 1 ? "Regular" : "Irregular",
          "implant_surface": _decodeSurface(implantSurface),
          "implant_diameter_mm": implantDiameterMm,
          "implant_length_mm": implantLengthMm,
          "prosthesis_type": _decodeProsthesis(prosthesisType),
          "cemented_restoration": cementedRestoration == 1 ? "Yes" : "No",
          "platform_switching": platformSwitching == 1 ? "Yes" : "No",
          "time_in_function_months": timeInFunctionMonths,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception("Server connection timed out. The backend might be waking up (Render free tier). Please try again in 30 seconds.");
      }
      rethrow;
    }
  }

  String _decodeSurface(int val) {
    switch (val) {
      case 1: return 'Moderately_rough';
      case 2: return 'Rough';
      case 0: return 'Machined';
      default: return 'Moderately_rough';
    }
  }

  String _decodeProsthesis(int val) {
    switch (val) {
      case 2: return 'Single_crown';
      case 0: return 'Bridge';
      case 1: return 'Overdenture';
      default: return 'Single_crown';
    }
  }
}
