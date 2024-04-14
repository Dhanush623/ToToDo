import 'package:fluttertoast/fluttertoast.dart';

showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    fontSize: 16.0,
  );
}
