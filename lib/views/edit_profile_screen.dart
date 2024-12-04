import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_email/data_classes.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gmail_base_screen.dart';
import '../utils/other.dart';
import '../other_widgets/general.dart';
import '../other_widgets/profile_edit.dart';
import '../state_management/account_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  File? _imageFile;
  WebAttachment? _imageWebFile;
  bool _isHovering = false;
  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    final currentAccount = accountProvider.currentAccount!;

    accountProvider.fetchUserProfile().then((value) {
      _bioController.text = accountProvider.userProfile!.bio!;
      // Set birthdate if available
      if (accountProvider.userProfile!.birthdate != null) {
        setState(() {
          _selectedBirthdate = DateFormat('yyyy-MM-dd').parse(
            accountProvider.userProfile!.birthdate!,
          );
          _birthdateController.text = DateFormat('yyyy-MM-dd').format(
            _selectedBirthdate!,
          );
        });
      }
    }).catchError((error) {
      if (mounted) {
        showSnackBar(context, 'Error fetching profile: $error');
      }
    });

    _firstnameController.text = currentAccount.first_name;
    _lastnameController.text = currentAccount.last_name;
    _emailController.text = currentAccount.email;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // For getting Uint8List
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _imageWebFile = WebAttachment.fromPlatformFile(result.files.first);
        } else {
          _imageFile = File(result.files.first.path!);
        }
      });
    }
  }

  Future<void> _selectBirthdate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = pickedDate;
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _updateProfile() async {
    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    try {
      await accountProvider.updateProfile(
        firstName: _firstnameController.text,
        lastName: _lastnameController.text,
        email: _emailController.text,
        bio: _bioController.text,
        birthdate: _selectedBirthdate,
        // Use `File` for mobile/desktop
        profilePicture: kIsWeb ? null : _imageFile,
        // Use `Uint8List` for web
        profilePictureWeb: kIsWeb ? _imageWebFile : null,
      );

      if (mounted) {
        showSnackBar(context, AppLocalizations.of(context)!.profileUpdated);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final currentAccount = accountProvider.currentAccount!;

    return GmailBaseScreen(
      title: AppLocalizations.of(context)!.editProfile,
      addDrawer: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              getProfileImagePicker(currentAccount),
              const SizedBox(height: 16),
              getFirstNameField(context),
              const SizedBox(height: 16),
              getLastNameField(context),
              const SizedBox(height: 16),
              getEmailField(),
              const SizedBox(height: 16),
              getBirthdateField(context),
              const SizedBox(height: 16),
              getBioField(context),
              const SizedBox(height: 16),
              getUpdateProfileButton(context),
            ],
          ),
        ),
      ),
    );
  }

  TextField getBirthdateField(BuildContext context) {
    return TextField(
      controller: _birthdateController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.birthdate,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _selectBirthdate,
        ),
      ),
      readOnly: true,
      onTap: _selectBirthdate,
    );
  }

  MouseRegion getProfileImagePicker(Account currentAccount) {
    var backgroundImage = _imageWebFile != null
        ? MemoryImage(_imageWebFile!.bytes) // For web
        : _imageFile != null
            ? FileImage(_imageFile!) // For mobile/desktop
            : getImageFromAccount(currentAccount);
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _pickImage,
        child: ClipOval(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: backgroundImage,
              ),
              if (_isHovering) const ImagePickerOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  TextField getFirstNameField(BuildContext context) {
    return getTextField(
      _firstnameController,
      AppLocalizations.of(context)!.firstName,
    );
  }

  TextField getLastNameField(BuildContext context) {
    return getTextField(
      _lastnameController,
      AppLocalizations.of(context)!.lastName,
    );
  }

  TextField getEmailField() {
    return getTextField(_emailController, 'Email');
  }

  TextField getBioField(BuildContext context) {
    return getTextField(
      _bioController,
      AppLocalizations.of(context)!.bio,
      maxLines: 3,
    );
  }

  ElevatedButton getUpdateProfileButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _updateProfile,
      child: Text(AppLocalizations.of(context)!.saveSettingChanges),
    );
  }
}
