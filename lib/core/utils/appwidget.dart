import 'package:easy_localization/easy_localization.dart';
import 'package:impact_loop/core/notification_services/notification_service.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

import '../exports.dart';

class AppWidget {
  static createProgressDialog(BuildContext context, String msg) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            content: Row(
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Text(
                  msg,
                  style: TextStyle(color: AppColors.black, fontSize: 15.0),
                )
              ],
            ),
          );
        });
  }

//!---------------- Loading Dialog With Logo we will use it  -------------

  loadingDialogWithLogo({required bool isLoading, required Widget child}) {
    return OverlayLoaderWithAppIcon(
        isLoading: isLoading,
        circularProgressColor: AppColors.primary,
        borderRadius: 15.0,
        appIcon: Image.asset(ImageAssets.appIcon),
        child: Container(child: child));
  }

//!---------------- LoadingDialogWithText  ----------------

  static void loadingDialogWithText([BuildContext? context]) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'loading'.tr(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                CircularProgressIndicator(color: AppColors.accent),
              ],
            ),
          ),
        );
      },
    );
  }
}
