import 'package:flutter/material.dart';
import '../models/evento_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../widgets/evento_card.dart';
import '../utils/dialog_helper.dart';
import 'add_task_screen.dart';
import 'eventos_finalizados_screen.dart';
import '../widgets/edit_evento_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  
  List<Evento> _events = [];
  int currentIndex = 0;
  bool _agruparPorGrupo = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _firestoreService.getEventos();
    setState(() {
      _events = events;
    });
  }

  void _showEditSheet(BuildContext context, Evento evento) {
    showEditEventoBottomSheet(
      context: context,
      evento: evento,
      onSaved: () async {
        await _fetchEvents();
        if (mounted) {
          DialogHelper.mostrarSnackBar(context, "Tarea actualizada");
        }
      },
    );
  }

  Future<void> _handleDismiss(Evento evento, DismissDirection direction) async {
    // Cancelar notificación
    if (evento.notificationId != null) {
      await _notificationService.cancelarNotificacion(evento.notificationId!);
    }

    if (direction == DismissDirection.startToEnd) {
      // Marcar como completado
      await _firestoreService.marcarEventoComoCompletado(evento);
      if (mounted) {
        DialogHelper.mostrarSnackBar(context, '${evento.nombre} completado');
      }
    } else {
      // Eliminar
      await _firestoreService.eliminarEvento(evento.id);
      if (mounted) {
        DialogHelper.mostrarSnackBar(context, '${evento.nombre} eliminado');
      }
    }

    await _fetchEvents();
  }

  List<Widget> _buildItemsAgrupados() {
    final eventosNoFinalizados = _events.where((e) => !e.finalizado).toList();
    final Map<String, List<Evento>> porGrupo = {};

    for (final ev in eventosNoFinalizados) {
      porGrupo.putIfAbsent(ev.grupo, () => []).add(ev);
    }

    return porGrupo.entries.map((entry) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepPurple, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...entry.value.map(
              (ev) => EventoCard(
                evento: ev,
                onEdit: () => _showEditSheet(context, ev),
                onDismissed: (direction) => _handleDismiss(ev, direction),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Text("Agrupar"),
              Switch(
                value: _agruparPorGrupo,
                onChanged: (v) => setState(() => _agruparPorGrupo = v),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
        child: [
          ListView(
            key: ValueKey(_agruparPorGrupo),
            padding: const EdgeInsets.only(top: 20, bottom: 100),
            children: _agruparPorGrupo
                ? _buildItemsAgrupados()
                : _events
                    .where((e) => !e.finalizado)
                    .map(
                      (ev) => EventoCard(
                        evento: ev,
                        onEdit: () => _showEditSheet(context, ev),
                        onDismissed: (direction) => _handleDismiss(ev, direction),
                      ),
                    )
                    .toList(),
          ),
          const EventosFinalizadosScreen(),
        ][currentIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(_createRoute())
            .then((r) {
          if (r == true) _fetchEvents();
        }),
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Finalizados',
          ),
        ],
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const AddTaskScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
