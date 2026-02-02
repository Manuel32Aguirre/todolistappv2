import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String nombre;
  final String descripcion;
  final String fecha;
  final String hora;
  final bool prioridad;
  final bool finalizado;
  final String grupo;
  final int? notificationId;

  Evento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.prioridad,
    required this.finalizado,
    required this.grupo,
    this.notificationId,
  });

  factory Evento.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Evento(
      id: doc.id,
      nombre: d['nombreEvento'] ?? '',
      descripcion: d['descripcion'] ?? '',
      fecha: d['fecha'] ?? '',
      hora: d['hora'] ?? '',
      prioridad: d['prioridad'] ?? false,
      finalizado: d['finalizado'] ?? false,
      grupo: d['grupo'] ?? 'Sin grupo',
      notificationId: d['notificationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreEvento': nombre,
      'descripcion': descripcion,
      'fecha': fecha,
      'hora': hora,
      'prioridad': prioridad,
      'finalizado': finalizado,
      'grupo': grupo,
      'notificationId': notificationId,
    };
  }

  Evento copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? fecha,
    String? hora,
    bool? prioridad,
    bool? finalizado,
    String? grupo,
    int? notificationId,
  }) {
    return Evento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      prioridad: prioridad ?? this.prioridad,
      finalizado: finalizado ?? this.finalizado,
      grupo: grupo ?? this.grupo,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
