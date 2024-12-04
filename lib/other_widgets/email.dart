import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'general.dart';
import 'email_helper.dart';
import 'email_detailed.dart';
import '../constants.dart';
import '../data_classes.dart';
import '../state_management/account_provider.dart';
import '../state_management/email_provider.dart';
import '../utils/api_pipeline.dart';

class EmailTile extends StatefulWidget {
  final Email email;
  final GestureTapCallback onTap;
  final BuildContext context;
  final EmailsProvider emailsProvider;
  final bool isDisableReadColor;
  final bool isDetailed;
  final Map<int, OtherUserProfile> profileCache;

  const EmailTile({
    required this.email,
    required this.onTap,
    required this.context,
    required this.emailsProvider,
    super.key,
    this.isDisableReadColor = false,
    this.isDetailed = false,
    required this.profileCache,
  });

  @override
  State<EmailTile> createState() => _EmailTileState();
}

class _EmailTileState extends State<EmailTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    bool isFromMe =
        widget.email.sender_id == accountProvider.currentAccount!.userID;
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHovering) {
        setState(() {
          _isHovering = isHovering;
        });
      },
      child: Container(
        color: getEmailTileColor(context),
        child: ListTile(
          leading: GestureDetector(
            onTap: () {
              if (!isFromMe) {
                showUserProfilePopup(
                  context,
                  widget.email,
                  widget.profileCache,
                );
              }
            },
            child: getSenderAvatar(
              widget.email,
              accountProvider.currentAccount!,
            ),
          ),
          title: widget.isDetailed
              ? null
              : getEmailTitle(
                  widget.email,
                  isFromMe,
                  context,
                ),
          subtitle: widget.isDetailed
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildMetadataSection(
                      context,
                      widget.email,
                      isLargeTitle: false,
                    ),
                    const SizedBox(height: 14),
                    getPlainBodyText(
                      widget.email,
                      context,
                      addPrefix: widget.isDetailed,
                    )
                  ],
                )
              : getSimpleMetadata(context),
          trailing: getEmailTrailing(
              widget.email, context, widget.emailsProvider,
              doShowTime: !widget.isDetailed),
        ),
      ),
    );
  }

  Column getSimpleMetadata(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getPlainBodyText(widget.email, context),
        if (widget.email.labels.isNotEmpty)
          Wrap(
            spacing: 4,
            children: widget.email.labels
                .map(
                  (label) => Chip(
                    label: Text(
                      label.displayName,
                      style: TextStyle(
                        color: getTextColorForChip(label.color),
                        fontSize: 10,
                      ),
                    ),
                    backgroundColor: label.color,
                    padding: const EdgeInsets.all(2),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Color? getEmailTileColor(BuildContext context) {
    if (_isHovering) return Theme.of(context).hoverColor;
    if (widget.isDisableReadColor) return null;
    if (!widget.email.is_read) {
      if (Theme.of(context).brightness == Brightness.light) {
        return const Color.fromARGB(255, 255, 222, 150);
      }
      return const Color.fromARGB(255, 8, 43, 66);
    }
    return null;
  }
}

CircleAvatar getSenderAvatar(Email email, Account currentAccount) {
  bool isFromMe = email.sender_id == currentAccount.userID;
  if (isFromMe) {
    return CircleAvatar(
      backgroundImage: getImageFromAccount(currentAccount),
    );
  }
  if (email.sender_profile_url != null) {
    return _getSenderProfileAvatar(email.sender_profile_url!);
  }
  return CircleAvatar(
    backgroundColor: _getColorForSender(email.sender),
    child: Text(
      email.sender[0].toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

CircleAvatar _getSenderProfileAvatar(
  String senderProfileURL, {
  double? radius,
}) {
  return CircleAvatar(
    radius: radius,
    backgroundImage: CachedNetworkImageProvider(
      getUserProfileImageURL(
        senderProfileURL,
      ),
    ),
  );
}

RichText getEmailTitle(Email email, bool isFromMe, BuildContext context) {
  return RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    text: getSenderSpan(email, isFromMe, context),
  );
}

Column getEmailTrailing(
  Email email,
  BuildContext context,
  EmailsProvider emailsProvider, {
  bool doShowTime = true,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (doShowTime) ...[
        Text(
          formatTimeSent(email.sent_at, context),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey[600]
                : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4)
      ],
      GestureDetector(
        onTap: () => emailsProvider.performEmailAction(email, EmailAction.star),
        child: Icon(
          email.is_starred ? Icons.star : Icons.star_border,
          color: email.is_starred ? Colors.amber[700] : Colors.grey,
          size: 20,
        ),
      ),
    ],
  );
}

Text getPlainBodyText(
  Email email,
  BuildContext context, {
  bool addPrefix = false,
}) {
  String contentText =
      quill.Document.fromJson(jsonDecode(email.body)).toPlainText();
  if (addPrefix) {
    contentText = "${AppLocalizations.of(context)!.emailMessage}: $contentText";
  }
  return Text(
    contentText,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[700]
          : Colors.grey[400],
    ),
  );
}

TextSpan getSenderSpan(Email email, bool isFromMe, BuildContext context) {
  return TextSpan(
    children: [
      TextSpan(
        text: email.subject,
        style: TextStyle(
          fontWeight: email.is_read ? FontWeight.normal : FontWeight.bold,
          color: email.is_read
              ? Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[600]
                  : Colors.grey[400]
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      TextSpan(
        text: ' ${AppLocalizations.of(context)!.emailFrom} ',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[500]
              : Colors.grey[400],
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
      TextSpan(
        text: isFromMe ? AppLocalizations.of(context)!.me : email.sender,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : Colors.grey[400],
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
    ],
  );
}

Color _getColorForSender(String senderAddress) {
  int hash = senderAddress.hashCode;
  return Color.fromRGBO(
    (hash & 0xFF0000) >> 16,
    (hash & 0x00FF00) >> 8,
    hash & 0x0000FF,
    0.6,
  );
}

void showUserProfilePopup(
  BuildContext context,
  Email email,
  Map<int, OtherUserProfile> cache,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<OtherUserProfile>(
        future: fetchUserProfile(email.sender_id, cache),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.errorLoadProfile),
            );
          } else if (snapshot.hasData) {
            final userProfile = snapshot.data!;
            return getUserProfileAlert(context, email, userProfile);
          } else {
            return Center(
              child: Text(AppLocalizations.of(context)!.noProfileAvailable),
            );
          }
        },
      );
    },
  );
}

AlertDialog getUserProfileAlert(
  BuildContext context,
  Email email,
  OtherUserProfile userProfile,
) {
  return AlertDialog(
    title: Text(
      AppLocalizations.of(context)!.userProfile,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email.sender_profile_url != null)
          getUserProfileAlertProfilePic(context, email),
        const SizedBox(height: 10),
        Text(
          '${AppLocalizations.of(context)!.userFullName}: ${userProfile.firstName} ${userProfile.lastName}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          '${AppLocalizations.of(context)!.birthdate}: ${userProfile.birthdate ?? AppLocalizations.of(context)!.notAvailable}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          '${AppLocalizations.of(context)!.bio}: ${userProfile.bio}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}

Center getUserProfileAlertProfilePic(BuildContext context, Email email) {
  return Center(
    child: GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: CachedNetworkImage(
                imageUrl: getUserProfileImageURL(email.sender_profile_url!),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            );
          },
        );
      },
      child: _getSenderProfileAvatar(
        email.sender_profile_url!,
        radius: 50,
      ),
    ),
  );
}

Future<OtherUserProfile> fetchUserProfile(
  int senderId,
  Map<int, OtherUserProfile> cache,
) async {
  print("Fetching profile for sender ID: $senderId");
  print("Current cache keys: ${cache.keys}");

  if (!cache.containsKey(senderId)) {
    print("Cache miss for sender ID: $senderId");
    try {
      final response = await makeAPIRequest(
        url: Uri.parse('${API_Endpoints.OTHER_USER_PROFILE.value}$senderId'),
        method: 'GET',
      );
      print("API response received: $response");

      final fetchedProfile = OtherUserProfile.fromJson(response);
      cache[senderId] = fetchedProfile;
      print("Profile cached for sender ID: $senderId");

      return fetchedProfile;
    } catch (e) {
      print("Error fetching profile: $e");
      rethrow;
    }
  }

  print("Cache hit for sender ID: $senderId");
  return cache[senderId]!;
}
