import 'package:flutter/widgets.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ToastUtils {
  static show(BuildContext context, {String msg}) {
    showToast(
      msg,
      context: context,
    );
  }
}
