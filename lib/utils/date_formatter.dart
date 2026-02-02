import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static String fechaBonita(String fecha) {
    try {
      final parsed = DateTime.parse(fecha);
      final meses = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];
      return '${parsed.day} de ${meses[parsed.month - 1]} de ${parsed.year}';
    } catch (_) {
      return fecha;
    }
  }

  static String formatearFecha(DateTime fecha) {
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  static String formatearHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }
}
