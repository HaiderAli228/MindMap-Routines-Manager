import 'package:fluttertoast/fluttertoast.dart';
import 'package:notes/utils/app_colors.dart';

class ToastMsg {
  static toastMsg(String msgIS) {
    return Fluttertoast.showToast(
        fontSize: 18,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        msg: msgIS,
        backgroundColor: AppColors.themeColor,
        textColor: AppColors.themeTextColor);
  }
}
