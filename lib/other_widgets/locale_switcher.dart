import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state_management/locale_provider.dart';

const Locale localeEN = Locale('en');
const Locale localeVI = Locale('vi');
const TextStyle dropdownTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.black,
);

List<Widget> getLanguageChangeDropdown(
  Locale currentLocale,
  BuildContext context,
  LocaleProvider localeProvider,
  FocusNode focusNode,
) {
  final theme = Theme.of(context);
  final dropdownTextStyle = getDropdownTextStyle(context);
  final screenWidth = MediaQuery.of(context).size.width;
  final isCompact = screenWidth < 700;

  return [
    SizedBox(
      width: isCompact ? 40 : 150,
      child: Focus(
        focusNode: focusNode,
        child: isCompact
            ? IconButton(
                icon: Icon(
                  Icons.language,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                onPressed: () {
                  // Show a dialog or bottom sheet for language selection
                  showLanguageSelectionDialog(
                    context,
                    currentLocale,
                    localeProvider,
                  );
                },
              )
            : DropdownButtonFormField<Locale>(
                value: currentLocale,
                items: [
                  DropdownMenuItem<Locale>(
                    value: localeEN,
                    child: Text(
                      AppLocalizations.of(context)!.language_EN,
                      style: dropdownTextStyle,
                    ),
                  ),
                  DropdownMenuItem<Locale>(
                    value: localeVI,
                    child: Text(
                      AppLocalizations.of(context)!.language_VI,
                      style: dropdownTextStyle,
                    ),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    // Use the LocaleProvider to change the locale
                    localeProvider.setLocale(newLocale);
                  }
                },
                decoration: InputDecoration(
                  // Customize the border
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  // Customize the filled color
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  // Customize the content padding
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, // Reduced horizontal padding
                    vertical: 6.0, // Reduced vertical padding
                  ),
                  // Optional: customize the dropdown icon
                  suffixIcon: Icon(
                    Icons.language,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                style: dropdownTextStyle,
                dropdownColor: theme.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
              ),
      ),
    ),
  ];
}

TextStyle getDropdownTextStyle(BuildContext context) {
  final theme = Theme.of(context);
  return TextStyle(
    fontSize: 14, // Reduced font size for better fit on mobile
    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
  );
}

void showLanguageSelectionDialog(
  BuildContext context,
  Locale currentLocale,
  LocaleProvider localeProvider,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: DropdownButtonFormField<Locale>(
          value: currentLocale,
          items: [
            DropdownMenuItem<Locale>(
              value: localeEN,
              child: Text(
                AppLocalizations.of(context)!.language_EN,
              ),
            ),
            DropdownMenuItem<Locale>(
              value: localeVI,
              child: Text(
                AppLocalizations.of(context)!.language_VI,
              ),
            ),
          ],
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              localeProvider.setLocale(newLocale);
              Navigator.of(context).pop();
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      );
    },
  );
}
