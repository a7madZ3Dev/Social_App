import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../shared/styles/styles/icon_broken.dart';

/// defualt app Bar
PreferredSizeWidget appBar({
  /// required BuildContext context,
  bool centerTitle = false,
  String title = 'New Post',
  bool leading = false,
  bool automaticallyImplyLeading = true,
  double titleSpacing = 10.0,
  bool actions = false,
  required VoidCallback onPressed,
  List<Widget>? actionsList,
}) =>
    AppBar(
      leading: leading
          ? IconButton(
              onPressed: onPressed,
              icon: Icon(IconBroken.Arrow___Left_2),
              tooltip: 'back',
            )
          : null,
      title: Text(title),
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions ? actionsList : [],
    );

/// button
Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double height = 50.0,
  double radius = 5.0,
  double fontSize = 16.0,
  required VoidCallback function,
  required String text,
}) =>
    Container(
      width: width,
      height: height,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius,
        ),
        color: background,
      ),
    );

/// form field
Widget defaultFormField({
  Key? key,
  TextEditingController? controller,
  String? initialValue,
  required TextInputType type,
  void Function(String value)? onSubmit,
  void Function(String value)? onChange,
  VoidCallback? onTap,
  void Function(String? value)? onSaved,
  bool isPassword = false,
  required String? Function(String? value) validate,
  String? label,
  IconData? prefix,
  int maxLines = 1,
  IconData? suffix,
  VoidCallback? suffixPressed,
  bool isClickable = true,
  bool readOnly = false,
  bool showCursor = true,
  Color? fillColor,
  TextInputAction textInputAction = TextInputAction.next,
}) =>
    TextFormField(
      key: key,
      controller: controller,
      initialValue: initialValue,
      keyboardType: type,
      obscureText: isPassword,
      maxLines: maxLines,
      enabled: isClickable,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      onTap: onTap,
      validator: validate,
      showCursor: showCursor,
      readOnly: readOnly,
      onSaved: onSaved,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? IconButton(
                onPressed: suffixPressed,
                icon: Icon(
                  suffix,
                ),
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

/// text button
Widget defaultTextButton({
  required VoidCallback onPressed,
  required String label,
  bool isUpperCase = true,
  double fontSize = 15,
}) =>
    TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Text(
        isUpperCase ? label.toUpperCase() : label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
        ),
      ),
    );

/// hash tag with InkWell
Widget defaultHashButton({
  required VoidCallback onPressed,
  required String label,
  bool isUpperCase = true,
}) =>
    InkWell(
      onTap: onPressed,
      child: Text(
        isUpperCase ? label.toUpperCase() : label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 13.5,
          color: Colors.blue,
        ),
      ),
    );

/// hash tag with materialButton
Widget defaultMaterialButton({
  required VoidCallback onPressed,
  required String label,
  bool isUpperCase = true,
}) =>
    MaterialButton(
      onPressed: onPressed,
      minWidth: 1.0,
      height: 25.0,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Text(
        isUpperCase ? label.toUpperCase() : label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.blue,
        ),
      ),
    );

/// simple divider
Widget myDivider() => Container(
      width: double.infinity,
      height: 1.0,
      color: Colors.grey[300],
    );

/// push to another screen
void navigateTo(BuildContext context, Widget widget) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

/// push to another screen and remove all the previous screens
void navigateAndFinish(BuildContext context, Widget widget) =>
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (Route<dynamic> route) => false,
    );

/// replacement last screen with another screen
void navigateAndReplacement(BuildContext context, Widget widget) =>
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
    );

/// toast message to show
void showToast({
  @required String? text,
  @required ToastStates? state,
}) =>
    Fluttertoast.showToast(
      msg: text!,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: chooseToastColor(state!),
      textColor: Colors.white,
      fontSize: 16.0,
    );

/// enum
enum ToastStates { SUCCESS, ERROR, WARNING }

/// background color for toast message
Color chooseToastColor(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}

/// background color for toast message
Color chooseToastColorTwo(ToastStates state) {
  Color color;

  switch (state) {
    case ToastStates.SUCCESS:
      color = Colors.green;
      break;
    case ToastStates.ERROR:
      color = Colors.red;
      break;
    case ToastStates.WARNING:
      color = Colors.amber;
      break;
  }

  return color;
}
