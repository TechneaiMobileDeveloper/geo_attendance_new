import 'package:geo_attendance_system/res/strings.dart';

class Validator {
  static Pattern mobilePattern = r'^\+?[0-9]{10}$';

  static Pattern userNamePattern =
      r'^(?=[a-zA-Z0-9._]{3,20}$)(?!.*[_.]{2})[^_.].*[^_.]$';

  static Pattern emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  static Pattern urlPattern =
      r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-@]+))*$";

  static String validateEmptyCheck(String value,
      {String errorMessage = Strings.invalidInput}) {
    if (value.isEmpty) return errorMessage;
    return null;
  }

  // static String validateInstanceURL(String value) {
  //   if (value.isEmpty) return Strings.instanceError;
  //   RegExp regexEmail = RegExp(urlPattern);
  //   if (regexEmail.hasMatch(value))
  //     return null;
  //   else
  //     return Strings.instanceError;
  // }

  static String validatePassword(String value) {
    if (value.isEmpty) return Strings.passValidation;
    return null;
  }

  static String validatePhone(String value) {
    if (value.isEmpty) return Strings.validPhone;
    RegExp regexPhone = RegExp(mobilePattern);
    if (regexPhone.hasMatch(value))
      return null;
    else
      return Strings.validPhone;
  }

  static String validateEmail(String value) {
    if (value.isEmpty) return Strings.validEmail;
    RegExp regexEmail = RegExp(emailPattern);
    if (regexEmail.hasMatch(value))
      return null;
    else
      return Strings.validEmail;
  }

  static String validateUsername(String value) {
    if (value.isEmpty) return Strings.usernameBlank;
    RegExp regexUserName = RegExp(userNamePattern);
    if (regexUserName.hasMatch(value))
      return null;
    else
      return Strings.usernameInvalid;
  }
}
