import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class EventosFinalizadosScreen extends StatefulWidget {
  const EventosFinalizadosScreen({super.key});

  @override
  State<EventosFinalizadosScreen> createState() =>
      _EventosFinalizadosScreenState();
}

class _EventosFinalizadosScreenState extends State<EventosFinalizadosScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _eliminarTodosFinalizados() async {
    await _firestoreService.eliminarTodosCompletados();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los eventos finalizados han sido eliminados'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizados'), centerTitle: true),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getEventosCompletadosStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error al cargar'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text('No hay eventos finalizados'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 12,
                  right: 12,
                  bottom: 70,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final nombre = data['nombreEvento'] ?? '';
                  final fecha = data['fecha'] ?? '';
                  final hora = data['hora'] ?? '';
                  final descripcion = data['descripcion'] ?? '';
                  final prioridad = data['prioridad'] ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade300,
                        width: 1.5,
                      ),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '$fecha  $hora',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing: prioridad
                          ? const Icon(
                              Icons.priority_high,
                              color: Colors.redAccent,
                            )
                          : null,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(nombre),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Descripción: $descripcion'),
                                const SizedBox(height: 10),
                                Text('Fecha: $fecha'),
                                Text('Hora: $hora'),
                                Text('Prioridad: ${prioridad ? 'Sí' : 'No'}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cerrar'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: ElevatedButton.icon(
              onPressed: _eliminarTodosFinalizados,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
              icon: const Icon(Icons.delete_sweep, color: Colors.black),
              label: const Text(
                'Eliminar todos',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
