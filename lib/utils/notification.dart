import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showTopNotification(BuildContext context, String message, Color color) {
  Flushbar(
    message: message,
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(12),
    animationDuration: const Duration(milliseconds: 400),
  ).show(context);
}
