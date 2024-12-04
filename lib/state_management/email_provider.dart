import 'package:flutter/foundation.dart';
import 'notification_provider.dart';
import 'web_soccer.dart';
import '../constants.dart';
import '../data_classes.dart';
import '../utils/api_pipeline.dart';

class EmailsProvider extends ChangeNotifier {
  List<Email> _filteredEmails = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  final Map<String, List<Email>> _emailCache = {};
  final Map<int, Email> _emailIdMap = {};
  final Map<String, DateTime> _cacheTimes = {};
  static const Duration CACHE_DURATION = Duration(minutes: 5);
  WebSocketService? _webSocketService;

  void initializeWebSocket(UserNotificationProvider notificationProvider) {
    _webSocketService = WebSocketService(this, notificationProvider);
    _webSocketService?.connect();
  }

  void addNewEmailToCache(Email newEmail, {String mailbox = 'inbox'}) {
    _emailCache.putIfAbsent(mailbox, () => []);
    print("Adding to cache");
    print(newEmail);
    print(newEmail.attachments);

    _emailCache[mailbox]!.insert(0, newEmail);
    _emailIdMap[newEmail.message_id] = newEmail;
    _cacheTimes[mailbox] = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService?.dispose();
    super.dispose();
  }

  void updateEmailInCache(Email updatedEmail) {
    for (var folder in _emailCache.values) {
      final index =
          folder.indexWhere((e) => e.message_id == updatedEmail.message_id);
      if (index != -1) {
        folder[index] = updatedEmail;
      }
    }
    notifyListeners();
  }

  void removeEmailFromCache(String messageId) {
    for (var folder in _emailCache.values) {
      folder.removeWhere((e) => e.message_id == messageId);
    }
    notifyListeners();
  }

  bool isCacheStale(String mailbox) {
    return !_emailCache.containsKey(mailbox) ||
        _cacheTimes[mailbox] == null ||
        DateTime.now().difference(_cacheTimes[mailbox]!) >= CACHE_DURATION;
  }

  List<Email> get emails =>
      _filteredEmails.isNotEmpty ? _filteredEmails : _emailCache['inbox'] ?? [];
  List<Email> get sentEmails =>
      _filteredEmails.isNotEmpty ? _filteredEmails : _emailCache['sent'] ?? [];
  List<Email> get trashedEmails =>
      _filteredEmails.isNotEmpty ? _filteredEmails : _emailCache['trash'] ?? [];
  List<Email> get starredEmails => _filteredEmails.isNotEmpty
      ? _filteredEmails
      : _emailCache['starred'] ?? [];
  List<Email> get allEmails =>
      _filteredEmails.isNotEmpty ? _filteredEmails : _emailCache['all'] ?? [];
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  WebSocketService? get webSocketService => _webSocketService;

  List<Email> getFolder(String folderName) {
    return _emailCache[folderName] ?? [];
  }

  Future<void> performEmailAction(Email email, EmailAction action,
      {String? mailbox}) async {
    bool originalState = _getBoolState(email, action);
    _toggleEmailState(email, action);
    notifyListeners();

    try {
      final body = {
        'message_id': email.message_id,
        'action': _mapActionToString(action),
        'bool_state': _getBoolState(email, action)
      };

      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.EMAIL_ACTION.value),
        method: 'POST',
        body: body,
      );

      final updatedEmail = Email.fromJson(responseData);
      _updateEmailInList(updatedEmail);
      if (mailbox != null) {
        updateFolders(
            mailbox, updatedEmail, _getBoolState(email, action), action);
      }
      notifyListeners();
    } catch (e) {
      _revertEmailState(email, action, originalState);
      _handleError('Error performing email action: $e');
    }
  }

  void updateFolders(
      String mailbox, Email updatedEmail, bool boolState, EmailAction action) {
    final mailFolder = getFolder(mailbox);
    final inboxIndex =
        mailFolder.indexWhere((e) => e.message_id == updatedEmail.message_id);

    if (action == EmailAction.star) {
      if (inboxIndex != -1) {
        mailFolder[inboxIndex] = updatedEmail;
      }
      return;
    }

    if (action == EmailAction.moveToTrash &&
        mailbox != MailBox.TRASH.value &&
        boolState &&
        inboxIndex != -1) {
      mailFolder.removeAt(inboxIndex);
      return;
    }

    if (boolState) {
      if (inboxIndex != -1) {
        mailFolder[inboxIndex] = updatedEmail;
      } else {
        mailFolder.add(updatedEmail);
      }
      return;
    }

    if (inboxIndex != -1 && action == EmailAction.moveToTrash) {
      mailFolder.removeAt(inboxIndex);
    }
  }

  void _updateEmailInList(Email updatedEmail) {
    if (_emailIdMap.containsKey(updatedEmail.message_id)) {
      _emailIdMap[updatedEmail.message_id] = updatedEmail;
      for (var folder in _emailCache.values) {
        final inboxIndex =
            folder.indexWhere((e) => e.message_id == updatedEmail.message_id);
        if (inboxIndex != -1) {
          folder[inboxIndex] = updatedEmail;
          break;
        }
      }
      notifyListeners();
    }
  }

  Future<void> updateEmailLabels(
      {required Email email, required EmailLabel label}) async {
    final originalLabels = List<EmailLabel>.from(email.labels);
    bool shouldAdd = !originalLabels.contains(label);

    if (shouldAdd) {
      email.addLabel(label);
    } else {
      email.removeLabel(label);
    }

    try {
      final body = {
        'message_id': email.message_id,
        'label_id': label.id,
        'action': shouldAdd ? 'add_label' : 'remove_label',
      };

      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.EMAIL_LABEL.value),
        method: 'POST',
        body: body,
      );

      final updatedEmail = Email.fromJson(responseData);
      _updateEmailInList(updatedEmail);
      notifyListeners();
    } catch (e) {
      email.labels = originalLabels;
      _handleError('Error updating email labels: $e');
    }
  }

  void refreshEmails({String mailbox = "inbox"}) {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    _filteredEmails.clear();
    fetchEmails(mailbox: mailbox, forceRefresh: true);
  }

  void filterEmails(
    String? keyword, {
    DateTime? startDate,
    DateTime? endDate,
    bool hasAttachments = false,
    String? label,
    String mailbox = "inbox",
  }) {
    print(keyword);
    print("Searching in $mailbox");
    if ((keyword == null || keyword.isEmpty) &&
        startDate == null &&
        endDate == null &&
        label == null &&
        !hasAttachments) {
      _filteredEmails.clear();
      _filteredEmails = getFolder(mailbox);
    } else {
      _filteredEmails = getFolder(mailbox).where((email) {
        bool matchesKeyword = keyword == null ||
            keyword.isEmpty ||
            email.subject.contains(keyword) ||
            email.body.contains(keyword);
        bool matchesDateRange =
            (startDate == null || email.sent_at.isAfter(startDate)) &&
                (endDate == null || email.sent_at.isBefore(endDate));
        bool matchesAttachments =
            !hasAttachments || email.attachments.isNotEmpty;
        bool matchesLabel = label == null ||
            email.labels.any((emailLabel) => emailLabel.displayName == label);
            print("Here");
            print("matchesKeyword: $matchesKeyword");
            print("matchesDateRange: $matchesDateRange");
            print("matchesAttachments: $matchesAttachments");
            print("matchesLabel: $matchesLabel");
        return matchesKeyword &&
            matchesDateRange &&
            matchesAttachments &&
            matchesLabel;
      }).toList();
      print(_filteredEmails);
    }
    notifyListeners();
  }

  Future<void> fetchEmails({
    String mailbox = 'inbox',
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheFresh(mailbox)) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    print("Fetching emails");

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();

      final responseData = await makeAPIRequest(
        url: Uri.parse('${API_Endpoints.EMAIL_LIST.value}?mailbox=$mailbox'),
        method: 'GET',
      );

      final parsedEmails = parseResponseToEmails(responseData);
      _updateEmailList(mailbox, parsedEmails);
      _cacheTimes[mailbox] = DateTime.now();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _handleError('Error fetching emails: $e');
    }
  }

  bool _isCacheFresh(String mailbox) {
    return _emailCache.containsKey(mailbox) &&
        _cacheTimes[mailbox] != null &&
        DateTime.now().difference(_cacheTimes[mailbox]!) < CACHE_DURATION;
  }

  Future<void> forceRefreshEmails({String mailbox = 'inbox'}) async {
    _emailCache.remove(mailbox);
    _cacheTimes.remove(mailbox);
    await fetchEmails(mailbox: mailbox);
  }

  void clearCache({String? mailbox}) {
    if (mailbox != null) {
      _emailCache.remove(mailbox);
      _cacheTimes.remove(mailbox);
    } else {
      _emailCache.clear();
      _cacheTimes.clear();
    }
    notifyListeners();
  }

  String _mapActionToString(EmailAction action) {
    switch (action) {
      case EmailAction.markRead:
        return 'mark_read';
      case EmailAction.star:
        return 'star';
      case EmailAction.moveToTrash:
        return 'move_to_trash';
    }
  }

  bool _getBoolState(Email email, EmailAction action) {
    switch (action) {
      case EmailAction.markRead:
        return email.is_read;
      case EmailAction.star:
        return email.is_starred;
      case EmailAction.moveToTrash:
        return email.is_trashed;
    }
  }

  void _toggleEmailState(Email email, EmailAction action) {
    switch (action) {
      case EmailAction.markRead:
        email.toggleReadStatus();
        break;
      case EmailAction.star:
        email.toggleStarStatus();
        break;
      case EmailAction.moveToTrash:
        email.toggleTrashStatus();
        break;
    }
  }

  void _revertEmailState(Email email, EmailAction action, bool originalState) {
    switch (action) {
      case EmailAction.markRead:
        email.is_read = originalState;
        break;
      case EmailAction.star:
        email.is_starred = originalState;
        break;
      case EmailAction.moveToTrash:
        email.is_trashed = originalState;
        break;
    }
  }

  void _updateEmailList(String mailbox, List<Email> parsedEmails) {
    _emailCache[mailbox] = parsedEmails;
  }

  void _handleError(String message) {
    _isLoading = false;
    _hasError = true;
    _errorMessage = message;
    print(_errorMessage);
    notifyListeners();
  }
}

List<Email> parseResponseToEmails(responseData) {
  return (responseData as List).map((json) => Email.fromJson(json)).toList();
}
