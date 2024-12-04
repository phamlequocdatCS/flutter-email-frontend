import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../state_management/draft_provider.dart';
import 'gmail_base_screen.dart';
import 'gmail_compose_email_screen.dart';

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.drafts,
      addDrawer: false,
      body: Consumer<DraftsProvider>(
        builder: (context, draftsProvider, child) {
          if (draftsProvider.drafts.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noEmails),
            );
          }

          return ListView.builder(
            itemCount: draftsProvider.drafts.length,
            itemBuilder: (context, index) {
              final draft = draftsProvider.drafts[index];
              return ListTile(
                title: Text(
                  draft.subject.isEmpty ? 'Untitled Draft' : draft.subject,
                ),
                subtitle: Text(
                  'To: ${draft.recipients.join(", ")}',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${draft.createdAt.day}/${draft.createdAt.month}/${draft.createdAt.year}',
                ),
                onTap: () {
                  // Navigate to email compose screen with draft
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailComposeScreen(
                        draftToEdit: draft,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.delete),
                      content: Text(
                        AppLocalizations.of(context)!.deleteConfirmation,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            draftsProvider.deleteDraft(draft.id);
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.delete),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
