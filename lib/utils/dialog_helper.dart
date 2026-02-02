import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DialogHelper {
  static void mostrarExito(
    BuildContext context,
    String titulo,
    String mensaje, {
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: titulo,
      desc: mensaje,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  static void mostrarError(
    BuildContext context,
    String titulo,
    String mensaje, {
    VoidCallback? onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: titulo,
      desc: mensaje,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  static void mostrarSnackBar(
    BuildContext context,
    String mensaje, {
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
