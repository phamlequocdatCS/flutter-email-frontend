import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftEmail {
  final String id;
  final List<String> recipients;
  final List<String>? ccRecipients;
  final List<String>? bccRecipients;
  final String subject;
  final String body;
  final List? attachments;
  final DateTime createdAt;

  DraftEmail({
    required this.id,
    required this.recipients,
    this.ccRecipients,
    this.bccRecipients,
    required this.subject,
    required this.body,
    this.attachments,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipients': recipients,
        'ccRecipients': ccRecipients,
        'bccRecipients': bccRecipients,
        'subject': subject,
        'body': body,
        // 'attachments': attachments?.map((a) => a.path).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory DraftEmail.fromJson(Map<String, dynamic> json) => DraftEmail(
        id: json['id'],
        recipients: List<String>.from(json['recipients']),
        ccRecipients: json['ccRecipients'] != null
            ? List<String>.from(json['ccRecipients'])
            : null,
        bccRecipients: json['bccRecipients'] != null
            ? List<String>.from(json['bccRecipients'])
            : null,
        subject: json['subject'],
        body: json['body'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class DraftsProvider extends ChangeNotifier {
  static const String DRAFTS_KEY = 'email_drafts';
  List<DraftEmail> _drafts = [];

  List<DraftEmail> get drafts => _drafts;

  DraftsProvider() {
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getStringList(DRAFTS_KEY) ?? [];
    _drafts = draftsJson
        .map((draftJson) => DraftEmail.fromJson(json.decode(draftJson)))
        .toList();
    notifyListeners();
  }

  Future<void> saveDraft(DraftEmail draft) async {
    final existingIndex = _drafts.indexWhere((d) => d.id == draft.id);
    
    if (existingIndex != -1) {
      _drafts[existingIndex] = draft;
    } else {
      _drafts.add(draft);
    }

    await _persistDrafts();
    notifyListeners();
  }

  Future<void> _persistDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = _drafts.map((draft) => json.encode(draft.toJson())).toList();
    await prefs.setStringList(DRAFTS_KEY, draftsJson);
  }

  Future<void> deleteDraft(String draftId) async {
    _drafts.removeWhere((draft) => draft.id == draftId);
    await _persistDrafts();
    notifyListeners();
  }

  DraftEmail? getDraftById(String draftId) {
    return _drafts.firstWhere((draft) => draft.id == draftId);
  }
}