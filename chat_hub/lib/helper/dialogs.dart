import 'package:flutter/material.dart';

class Dialogs {
  static void showSnakBar(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(0.8),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void onProgress(BuildContext context) {
    showDialog(context: context, builder:(_) => Center(child: CircularProgressIndicator()));
  }
}
