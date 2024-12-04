import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../data_classes.dart';
import '../other_widgets/general.dart';
import '../state_management/label_provider.dart';

class LabelManagementScreen extends StatefulWidget {
  const LabelManagementScreen({super.key});

  @override
  State<LabelManagementScreen> createState() => _LabelManagementScreenState();
}

class _LabelManagementScreenState extends State<LabelManagementScreen> {
  final TextEditingController _labelNameController = TextEditingController();
  Color _selectedColor = LabelColorPreset.blue.color;

  @override
  void initState() {
    super.initState();
    // Fetch labels when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();
    });
  }

  void _showLabelDialog({
    LabelManagementAction action = LabelManagementAction.create,
    EmailLabel? existingLabel,
  }) {
    // Reset or populate controller based on action
    if (action == LabelManagementAction.create) {
      _labelNameController.clear();
      _selectedColor = LabelColorPreset.blue.color;
    } else if (action == LabelManagementAction.edit && existingLabel != null) {
      _labelNameController.text = existingLabel.displayName;
      _selectedColor = existingLabel.color;
    } else if (action == LabelManagementAction.delete) {
      _showDeleteConfirmationDialog(existingLabel);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(getLabelActionText(action, context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getLabelNameField(context),
            const SizedBox(height: 16),
            getColorPicker(),
          ],
        ),
        actions: [
          getCancelButton(context),
          getSaveLabelButton(action, existingLabel, context),
        ],
      ),
    );
  }

  String getLabelActionText(
    LabelManagementAction action,
    BuildContext context,
  ) {
    return action == LabelManagementAction.create
        ? AppLocalizations.of(context)!.createLabel
        : AppLocalizations.of(context)!.editLabel;
  }

  TextField getLabelNameField(BuildContext context) {
    return getTextField(
      _labelNameController,
      AppLocalizations.of(context)!.labelName,
    );
  }

  ColorPicker getColorPicker() {
    return ColorPicker(
      pickerColor: _selectedColor,
      onColorChanged: (Color color) {
        setState(() {
          _selectedColor = color;
        });
      },
      pickerAreaHeightPercent: 0.8,
    );
  }

  ElevatedButton getSaveLabelButton(
    LabelManagementAction action,
    EmailLabel? existingLabel,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (_labelNameController.text.isNotEmpty) {
          _handleLabelAction(action, existingLabel);
          Navigator.of(context).pop();
        }
      },
      child: Text(AppLocalizations.of(context)!.saveSettingChanges),
    );
  }

  void _showDeleteConfirmationDialog(EmailLabel? existingLabel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteLabel),
        content: Text(AppLocalizations.of(context)!.deleteConfirmation),
        actions: [
          getCancelButton(context),
          getDeleteConfirmButton(existingLabel, context),
        ],
      ),
    );
  }

  ElevatedButton getDeleteConfirmButton(
    EmailLabel? existingLabel,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: () {
        _handleLabelAction(LabelManagementAction.delete, existingLabel);
        Navigator.of(context).pop();
      },
      child: Text(AppLocalizations.of(context)!.delete),
    );
  }

  TextButton getCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(AppLocalizations.of(context)!.cancel),
    );
  }

  Future<void> _handleLabelAction(
    LabelManagementAction action,
    EmailLabel? existingLabel,
  ) async {
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);
    final color = '#${_selectedColor.value.toRadixString(16).substring(2)}';
    final name = _labelNameController.text;

    bool success = false;
    switch (action) {
      case LabelManagementAction.create:
        success = await labelProvider.createLabel(
          name: name,
          color: color,
        );
        break;
      case LabelManagementAction.edit:
        if (existingLabel != null) {
          success = await labelProvider.updateLabel(
            originalLabel: existingLabel,
            newName: name,
            newColor: color,
          );
        }
        break;
      case LabelManagementAction.delete:
        if (existingLabel != null) {
          success = await labelProvider.deleteLabel(existingLabel);
        }
        break;
    }

    // Show feedback
    if (success) {
      if (mounted) {
        showSnackBar(
          context,
          getLabelSuccessText(action),
        );
      }
    } else {
      if (mounted) {
        showSnackBar(
          context,
          AppLocalizations.of(context)!.errorSavingSettings,
        );
      }
    }
  }

  String getLabelSuccessText(LabelManagementAction action) {
    return action == LabelManagementAction.create
        ? AppLocalizations.of(context)!.labelCreated
        : action == LabelManagementAction.edit
            ? AppLocalizations.of(context)!.labelUpdated
            : AppLocalizations.of(context)!.labelDeleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.labelManagement),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLabelDialog(),
        child: const Icon(Icons.add),
      ),
      body: Consumer<LabelProvider>(
        builder: labelManagementBuilder,
      ),
    );
  }

  Widget labelManagementBuilder(context, labelProvider, child) {
    // Show loading indicator
    if (labelProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message if there's an error
    if (labelProvider.errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          labelProvider.errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return ListView.builder(
      itemCount: labelProvider.labels.length,
      itemBuilder: (context, index) {
        final label = labelProvider.labels[index];
        return getLabelTile(label);
      },
    );
  }

  ListTile getLabelTile(EmailLabel label) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        color: label.color,
      ),
      title: Text(label.displayName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          getEditLabelButton(label),
          getDeleteLabelButton(label),
        ],
      ),
    );
  }

  IconButton getDeleteLabelButton(EmailLabel label) {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () => _showLabelDialog(
        action: LabelManagementAction.delete,
        existingLabel: label,
      ),
    );
  }

  IconButton getEditLabelButton(EmailLabel label) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _showLabelDialog(
        action: LabelManagementAction.edit,
        existingLabel: label,
      ),
    );
  }

  @override
  void dispose() {
    _labelNameController.dispose();
    super.dispose();
  }
}
