import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _eventosCollection = 'evento';
  static const String _completadosCollection = 'completado';

  Future<List<Evento>> getEventos() async {
    final snap = await _db.collection(_eventosCollection).get();
    return snap.docs.map((d) => Evento.fromDoc(d)).toList();
  }

  Stream<List<Evento>> getEventosStream() {
    return _db.collection(_eventosCollection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Evento.fromDoc(doc)).toList(),
    );
  }

  Future<List<String>> getGruposDisponibles() async {
    final snap = await _db.collection(_eventosCollection).get();
    final grupos = <String>{};

    for (final doc in snap.docs) {
      final grupo = doc['grupo'];
      if (grupo != null && grupo is String && grupo.isNotEmpty) {
        grupos.add(grupo);
      }
    }

    return grupos.toList()..sort();
  }

  Future<String> crearEvento(Map<String, dynamic> eventoData) async {
    final docRef = await _db.collection(_eventosCollection).add(eventoData);
    return docRef.id;
  }

  Future<void> actualizarEvento(String eventoId, Map<String, dynamic> data) async {
    await _db.collection(_eventosCollection).doc(eventoId).update(data);
  }

  Future<void> eliminarEvento(String eventoId) async {
    await _db.collection(_eventosCollection).doc(eventoId).delete();
  }

  Future<void> marcarEventoComoCompletado(Evento evento) async {
    await _db.collection(_completadosCollection).doc(evento.id).set({
      'nombreEvento': evento.nombre,
      'descripcion': evento.descripcion,
      'fecha': evento.fecha,
      'hora': evento.hora,
      'prioridad': evento.prioridad,
      'finalizado': true,
      'notificationId': evento.notificationId,
    });
    await eliminarEvento(evento.id);
  }

  Stream<QuerySnapshot> getEventosCompletadosStream() {
    return _db.collection(_completadosCollection).snapshots();
  }

  Future<void> eliminarTodosCompletados() async {
    final completados = await _db.collection(_completadosCollection).get();
    for (final doc in completados.docs) {
      await doc.reference.delete();
    }
  }
}
