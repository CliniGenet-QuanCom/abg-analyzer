import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/abg_input.dart';

/// 1 件の解析履歴。
class HistoryEntry {
  final DateTime timestamp;
  final AbgInput input;
  final String primaryDiagnosis;
  final bool pediatric;
  final bool venous;

  const HistoryEntry({
    required this.timestamp,
    required this.input,
    required this.primaryDiagnosis,
    required this.pediatric,
    this.venous = false,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'input': input.toJson(),
        'primaryDiagnosis': primaryDiagnosis,
        'pediatric': pediatric,
        'venous': venous,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        input: AbgInput.fromJson(json['input'] as Map<String, dynamic>),
        primaryDiagnosis: json['primaryDiagnosis'] as String? ?? '',
        pediatric: json['pediatric'] as bool? ?? false,
        venous: json['venous'] as bool? ?? false,
      );
}

/// SharedPreferences に履歴と設定を保存するリポジトリ。
class HistoryRepository {
  static const _historyKey = 'abg_history';
  static const _disclaimerKey = 'abg_disclaimer_accepted';
  static const _localeKey = 'abg_locale';
  static const _maxEntries = 100;

  /// 保存された言語コード（null = 端末設定に従う）。
  Future<String?> getLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  /// 言語コードを保存（null で端末設定に戻す）。
  Future<void> setLocaleCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, code);
    }
  }

  Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await load();
    entries.insert(0, entry);
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }
    await prefs.setString(
        _historyKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<void> delete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await load();
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
    await prefs.setString(
        _historyKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<bool> isDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerKey) ?? false;
  }

  Future<void> setDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerKey, true);
  }
}
