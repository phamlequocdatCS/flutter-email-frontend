import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state_management/email_provider.dart';
import '../state_management/label_provider.dart';

Row getUltimateEmailBar(Widget viewToggleWidget, String mailbox) {
  return Row(
    children: [
      Expanded(
        child: EmailSearchBar(
          viewToggleWidget: viewToggleWidget,
          mailbox: mailbox,
        ),
      ),
    ],
  );
}

class EmailSearchBar extends StatefulWidget {
  final bool showAdvancedSearchButton;
  final bool showRefreshButton;
  final Widget viewToggleWidget;
  final String mailbox;

  const EmailSearchBar({
    super.key,
    this.showAdvancedSearchButton = true,
    this.showRefreshButton = true,
    required this.viewToggleWidget,
    required this.mailbox,
  });

  @override
  State<EmailSearchBar> createState() => _EmailSearchBarState();
}

class _EmailSearchBarState extends State<EmailSearchBar> {
  String _searchKeyword = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasAttachments = false;
  String? _selectedLabel;

  void _filterEmails() {
    Provider.of<EmailsProvider>(context, listen: false).filterEmails(
      _searchKeyword,
      startDate: _startDate,
      endDate: _endDate,
      hasAttachments: _hasAttachments,
      label: _selectedLabel,
      mailbox: widget.mailbox,
    );
  }

  void _showAdvancedSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.advancedSearch),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchKeyword = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.keyword,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDatePickerRow(
                        context,
                        AppLocalizations.of(context)!.startDate,
                        _startDate,
                        (picked) => setState(() {
                              _startDate = picked;
                            })),
                    const SizedBox(height: 10),
                    _buildDatePickerRow(
                        context,
                        AppLocalizations.of(context)!.endDate,
                        _endDate,
                        (picked) => setState(() {
                              _endDate = picked;
                            })),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: Text(AppLocalizations.of(context)!.hasAttachments),
                      value: _hasAttachments,
                      onChanged: (value) {
                        setState(() {
                          _hasAttachments = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildLabelDropdown(context),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () {
                    _filterEmails();
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.search),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDatePickerRow(
    BuildContext context,
    String label,
    DateTime? currentDate,
    Function(DateTime?) onDatePicked,
  ) {
    return Row(
      children: [
        Text(label),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: currentDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != currentDate) {
              onDatePicked(picked);
            }
          },
        ),
        Text(currentDate != null
            ? currentDate.toLocal().toString().split(' ')[0]
            : ''),
      ],
    );
  }

  Widget _buildLabelDropdown(BuildContext context) {
    return Consumer<LabelProvider>(
      builder: (context, labelProvider, child) {
        if (labelProvider.isLoading) {
          return const CircularProgressIndicator();
        }
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.label,
          ),
          value: _selectedLabel,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(AppLocalizations.of(context)!.allLabels),
            ),
            ...labelProvider.labels.map((label) => DropdownMenuItem(
                  value: label.displayName,
                  child: Text(label.displayName),
                ))
          ],
          onChanged: (value) {
            setState(() {
              _selectedLabel = value;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Main search field
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
              });
              _filterEmails();
            },
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.findInMail,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),

        // Conditional buttons based on widget configuration
        if (widget.showRefreshButton)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<EmailsProvider>(context, listen: false)
                  .refreshEmails(mailbox: widget.mailbox);
            },
          ),
        widget.viewToggleWidget,
        if (widget.showAdvancedSearchButton)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showAdvancedSearchDialog,
          ),
      ],
    );
  }
}
