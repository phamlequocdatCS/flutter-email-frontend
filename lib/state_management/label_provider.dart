import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../data_classes.dart';
import '../utils/api_pipeline.dart';

class LabelProvider extends ChangeNotifier {
  List<EmailLabel> _labels = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<EmailLabel> get labels => _labels;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch user's labels
  Future<void> fetchLabels() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_LABEL.value),
        method: 'GET',
      );

      // print(responseData);

      _labels = (responseData as List)
          .map((labelData) => EmailLabel.fromJson(labelData))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error fetching labels: ${e.toString()}';
      notifyListeners();
    }
  }

  // Create a new label
  Future<bool> createLabel({
    required String name,
    required String color,
  }) async {
    try {
      final body = {
        'name': name,
        'color': color,
        'action': 'create',
      };

      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_LABEL.value),
        method: 'POST',
        body: body,
      );

      // Add the new label to the local list
      final newLabel = EmailLabel.fromJson(responseData);
      _labels.add(newLabel);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating label: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update an existing label
  Future<bool> updateLabel({
    required EmailLabel originalLabel,
    required String newName,
    required String newColor,
  }) async {
    try {
      final body = {
        'id': originalLabel.id,
        'new_name': newName,
        'new_color': newColor,
        'action': 'edit',
      };

      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_LABEL.value),
        method: 'POST',
        body: body,
      );

      // Update the label in the local list
      final index = _labels.indexWhere(
          (label) => label.displayName == originalLabel.displayName);

      if (index != -1) {
        _labels[index] = EmailLabel.fromJson(responseData);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = 'Error updating label: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete a label
  Future<bool> deleteLabel(EmailLabel label) async {
    try {
      final body = {
        'id': label.id,
        'action': 'delete',
      };

      await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_LABEL.value),
        method: 'POST',
        body: body,
      );

      // Remove the label from the local list
      _labels.removeWhere((existingLabel) => existingLabel.id == label.id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting label: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Find a label by name
  EmailLabel? findLabelByName(String name) {
    try {
      return _labels.firstWhere(
          (label) => label.displayName.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
