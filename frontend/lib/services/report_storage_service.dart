import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportStorageService {
  static const String publicKey = 'analyzer_history_public';
  static const String globalKey = 'implantguard_all_history';

  static String getUserKey(String? uid) {
    if (uid != null && uid.isNotEmpty) {
      return 'analyzer_history_$uid';
    }
    return publicKey;
  }

  /// Save a prediction report across ALL keys so it is never lost regardless of login status
  static Future<void> saveReport(Map<String, dynamic> reportData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      // Ensure date and unique id exist
      if (!reportData.containsKey('date') || reportData['date'] == null) {
        reportData['date'] = DateTime.now().toIso8601String();
      }

      final dateStr = reportData['date'].toString();
      final scoreStr = (reportData['score'] ?? 0).toString();
      if (!reportData.containsKey('id') || reportData['id'] == null) {
        reportData['id'] = '${dateStr}_$scoreStr';
      }

      final String reportJson = jsonEncode(reportData);

      // Save to: public, global, and current user key (if logged in)
      final keysToSave = <String>{publicKey, globalKey};
      if (user != null && user.uid.isNotEmpty) {
        keysToSave.add(getUserKey(user.uid));
      }

      for (final key in keysToSave) {
        final existingList = prefs.getStringList(key)?.toList() ?? [];
        existingList.insert(0, reportJson);
        await prefs.setStringList(key, existingList);
      }
    } catch (e) {
      debugPrint("Error saving report to history: $e");
    }
  }

  /// Load ALL prediction history across public, user-specific, global, and legacy keys
  static Future<List<Map<String, dynamic>>> loadAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      // Find all keys starting with analyzer_history_ or implantguard_all_history
      final allKeys = prefs.getKeys();
      final keysToLoad = <String>{publicKey, globalKey};
      if (user != null && user.uid.isNotEmpty) {
        keysToLoad.add(getUserKey(user.uid));
      }

      for (final k in allKeys) {
        if (k.startsWith('analyzer_history_') || k == globalKey) {
          keysToLoad.add(k);
        }
      }

      final Map<String, Map<String, dynamic>> deduplicated = {};

      for (final key in keysToLoad) {
        final list = prefs.getStringList(key) ?? [];
        for (final itemStr in list) {
          try {
            final parsed = jsonDecode(itemStr) as Map<String, dynamic>;
            final dateStr = parsed['date']?.toString() ?? '';
            final scoreVal = parsed['score']?.toString() ?? '';
            final uniqueId = parsed['id']?.toString() ?? '${dateStr}_$scoreVal';

            if (dateStr.isNotEmpty && !deduplicated.containsKey(uniqueId)) {
              deduplicated[uniqueId] = parsed;
            }
          } catch (_) {}
        }
      }

      final resultList = deduplicated.values.toList();
      // Sort newest first
      resultList.sort((a, b) {
        final dateA = DateTime.tryParse(a['date']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = DateTime.tryParse(b['date']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      return resultList;
    } catch (e) {
      debugPrint("Error loading report history: $e");
      return [];
    }
  }
}
