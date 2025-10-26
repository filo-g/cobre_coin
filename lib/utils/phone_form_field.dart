import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PhoneFieldView extends StatelessWidget {
  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  final PhoneController controller;
  final FocusNode focusNode;
  final CountrySelectorNavigator selectorNavigator;
  final bool withLabel;
  final bool withDescription;
  final bool outlineBorder;
  final bool isCountryButtonPersistant;
  final bool mobileOnly;
  final Locale locale;

  PhoneFieldView({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectorNavigator,
    required this.withLabel,
    required this.withDescription,
    required this.outlineBorder,
    required this.isCountryButtonPersistant,
    required this.mobileOnly,
    required this.locale,
  });

  PhoneNumberInputValidator? _getValidator(BuildContext context) {
    List<PhoneNumberInputValidator> validators = [];
    if (mobileOnly) {
      validators.add(PhoneValidator.validMobile(context));
    } else {
      validators.add(PhoneValidator.valid(context));
    }
    return validators.isNotEmpty ? PhoneValidator.compose(validators) : null;
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Localizations.override(
        context: context,
        locale: locale,
        child: Builder(
          builder: (context) {
            final label = PhoneFieldLocalization.of(context).phoneNumber;
            final description = 'Your phone number.';

            return PhoneFormField(
              focusNode: focusNode,
              controller: controller,
              isCountryButtonPersistent: isCountryButtonPersistant,
              autofocus: false,
              autofillHints: const [AutofillHints.telephoneNumber],
              countrySelectorNavigator: selectorNavigator,
              decoration: InputDecoration(
                  label: withLabel ? Text(label) : null,
                  border: outlineBorder
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50))
                      : const UnderlineInputBorder(),
                  hintText: withLabel ? '' : label,
                  helperText: withDescription ? description : null,
                  contentPadding: const EdgeInsets.all(0)),
              enabled: true,
              countryButtonStyle: CountryButtonStyle(
                  showFlag: true,
                  showIsoCode: false,
                  showDialCode: true,
                  showDropdownIcon: true,
                  borderRadius: BorderRadius.circular(50)),

              validator: _getValidator(context),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              cursorColor: Theme.of(context).colorScheme.primary,
              // ignore: avoid_print
              onSaved: (p) => print('saved $p'),
              // ignore: avoid_print
              onChanged: (p) => print('changed $p'),
            );
          },
        ),
      ),
    );
  }
}