import 'package:flutter/material.dart';
import '../models/evento_model.dart';
import '../utils/date_formatter.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onEdit;
  final Function(DismissDirection) onDismissed;

  const EventoCard({
    super.key,
    required this.evento,
    required this.onEdit,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final fechaHoraEvento =
        DateTime.tryParse('${evento.fecha} ${evento.hora}') ?? DateTime.now();
    final yaPaso = DateTime.now().isAfter(fechaHoraEvento);

    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Dismissible(
          key: Key(evento.id),
          background: _buildSwipeBackground(
            Icons.check,
            'Completado',
            Colors.green,
            Alignment.centerLeft,
          ),
          secondaryBackground: _buildSwipeBackground(
            Icons.delete,
            'Eliminar',
            Colors.red,
            Alignment.centerRight,
          ),
          onDismissed: onDismissed,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: yaPaso
                  ? Colors.red.shade50
                  : (evento.prioridad
                      ? Colors.black.withOpacity(0.05)
                      : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: evento.prioridad
                  ? Border.all(color: Colors.blueAccent, width: 2)
                  : null,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${DateFormatter.fechaBonita(evento.fecha)}  ${evento.hora}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    IconData icon,
    String label,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
