// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

class EmailAttachment {
  final int file_id;
  final String filename;
  final String file_url;

  EmailAttachment({
    required this.file_id,
    required this.filename,
    required this.file_url,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': file_id,
      'filename': filename,
      'file_url': file_url,
    };
  }

  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(
      file_id: json['id'],
      filename: json['filename'],
      file_url: json['file'],
    );
  }
}

class EmailLabel {
  final int id;
  final String displayName;
  final Color color;

  EmailLabel({
    required this.id,
    required this.displayName,
    required this.color,
  });

  // Add a method to convert color to hex string
  String get colorHex {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static EmailLabel fromJson(Map<String, dynamic> json) {
    return EmailLabel(
      id: json['id'],
      displayName: json['name'],
      color: Color(
        int.parse(json['color'].substring(1), radix: 16) + 0xFF000000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': displayName,
      'color': colorHex,
    };
  }

  @override
  String toString() {
    return "$id $displayName $color";
  }

  bool operator ==(Object other) =>
      other is EmailLabel && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class Email {
  final int message_id;
  final int sender_id;
  final String sender;
  final String? sender_profile_url;
  final List<String> recipients;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final List<EmailAttachment> attachments;
  final DateTime sent_at;
  bool is_read;
  bool is_starred;
  bool is_draft;
  bool is_trashed;
  bool is_auto_replied;
  List<EmailLabel> labels;

  bool operator ==(Object other) =>
      other is Email &&
      other.runtimeType == runtimeType &&
      other.message_id == message_id;

  Email({
    required this.message_id,
    required this.sender_id,
    required this.sender,
    required this.sender_profile_url,
    required this.recipients,
    this.cc = const [],
    this.bcc = const [],
    required this.subject,
    required this.body,
    this.attachments = const [],
    required this.sent_at,
    this.is_read = false,
    this.is_starred = false,
    this.is_draft = false,
    this.is_trashed = false,
    this.is_auto_replied = false,
    this.labels = const [],
  });

  // Factory method to create from JSON
  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      message_id: json['id'],
      sender_id: json['sender_id'],
      sender: json['sender'],
      sender_profile_url: json['sender_profile_url'],
      recipients: List<String>.from(json['recipients'] ?? []),
      cc: List<String>.from(json['cc'] ?? []),
      bcc: List<String>.from(json['bcc'] ?? []),
      subject: json['subject'],
      body: json['body'],
      sent_at: DateTime.parse(json['sent_at']),
      attachments: (json['attachments'] as List?)
              ?.map((attach) => EmailAttachment.fromJson(attach))
              .toList() ??
          [],
      is_read: json['is_read'] ?? false,
      is_starred: json['is_starred'] ?? false,
      is_draft: json['is_draft'] ?? false,
      is_trashed: json['is_trashed'] ?? false,
      is_auto_replied: json['is_auto_replied'] ?? false,
      labels: (json['labels'] as List?)
              ?.map((attach) => EmailLabel.fromJson(attach))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': message_id,
      'sender_id': sender_id,
      'sender': sender,
      'sender_profile_url': sender_profile_url,
      'recipients': recipients,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'sent_at': sent_at.toIso8601String(),
      'attachments': attachments.map((attach) => attach.toJson()).toList(),
      'is_read': is_read,
      'is_starred': is_starred,
      'is_draft': is_draft,
      'is_trashed': is_trashed,
      'is_auto_replied': is_auto_replied,
      'labels': labels.map((label) => label.toJson()).toList(),
    };
  }

  // Method to toggle read status
  bool toggleReadStatus() {
    is_read = !is_read;
    return is_read;
  }

  // Method to toggle star status
  bool toggleStarStatus() {
    is_starred = !is_starred;
    return is_starred;
  }

  // Method to add a label
  void addLabel(EmailLabel label) {
    if (!labels.contains(label)) {
      labels.add(label);
    }
  }

  // Method to remove a label
  void removeLabel(EmailLabel label) {
    labels.remove(label);
  }

  // Method to move to trash
  bool toggleTrashStatus() {
    is_trashed = !is_trashed;
    return is_trashed;
  }
}

class Account {
  final String phone_number;
  final int userID;
  final String email;
  final String first_name;
  final String last_name;
  final String profile_picture;
  final bool is_phone_verified;

  Account({
    required this.phone_number,
    required this.userID,
    required this.email,
    required this.first_name,
    required this.last_name,
    required this.profile_picture,
    required this.is_phone_verified,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      phone_number: json['phone_number'],
      userID: json['id'],
      email: json['email'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      profile_picture: json['profile_picture'],
      is_phone_verified: json['is_phone_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phone_number,
      'id': userID,
      'email': email,
      'first_name': first_name,
      'last_name': last_name,
      'profile_picture': profile_picture,
      'is_phone_verified': is_phone_verified,
    };
  }

  @override
  String toString() {
    return 'phone_number: $phone_number - email: $email by first_name: $first_name';
  }
}

class OtherUserProfile {
  final String? firstName;
  final String? lastName;
  final String? birthdate;
  final String bio;

  OtherUserProfile({
    required this.firstName,
    required this.lastName,
    required this.birthdate,
    required this.bio,
  });

  factory OtherUserProfile.fromJson(Map<String, dynamic> json) {
    return OtherUserProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthdate: json['birthdate'],
      bio: (json['bio'] as String).isEmpty ? "None" : json['bio'],
    );
  }
}

class UserProfile {
  final String? bio;
  final String? birthdate;
  final bool two_factor_enabled;

  UserProfile({
    required this.bio,
    required this.birthdate,
    required this.two_factor_enabled,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'],
      birthdate: json['birthdate'],
      two_factor_enabled: json['two_factor_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'birthdate': birthdate,
      'two_factor_enabled': two_factor_enabled,
    };
  }

  @override
  String toString() {
    return 'bio: $bio - birthdate: $birthdate - two_factor_enabled: $two_factor_enabled';
  }
}

class NotificationData {
  final String notifTitle;
  final String notifSubtitle;

  NotificationData({required this.notifTitle, required this.notifSubtitle});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notifTitle: json['title'],
      notifSubtitle: json['subtitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': notifTitle,
      'subtitle': notifSubtitle,
    };
  }
}

enum EmailAction { markRead, star, moveToTrash }

enum LabelManagementAction { create, edit, delete }

class UserNotification {
  final int id;
  final String message;
  bool isRead;
  final DateTime createdAt;
  final String notificationType;
  final int? emailID;

  UserNotification({
    required this.emailID,
    required this.id,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.notificationType = 'system',
  });

  // JSON serialization
  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      emailID: json['related_email']['id'],
      id: json['id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      notificationType: json['notification_type'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
        'notification_type': notificationType,
      };

  // Optional: Equality and hashCode for proper comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
