import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/evento_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/grupo_selector.dart';

void showEditEventoBottomSheet({
  required BuildContext context,
  required Evento evento,
  required VoidCallback onSaved,
}) {
  final nombreCtrl = TextEditingController(text: evento.nombre);
  final descCtrl = TextEditingController(text: evento.descripcion);
  final fechaCtrl = TextEditingController(text: evento.fecha);
  final horaCtrl = TextEditingController(text: evento.hora);
  String? grupoSeleccionado = evento.grupo;
  bool prioridad = evento.prioridad;

  final firestoreService = FirestoreService();
  final notificationService = NotificationService();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Editar tarea",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: nombreCtrl,
                labelText: "Nombre del evento",
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descCtrl,
                labelText: "Descripción",
                prefixIcon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: fechaCtrl,
                      labelText: "Fecha",
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(fechaCtrl.text) ??
                              DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          fechaCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: horaCtrl,
                      labelText: "Hora",
                      prefixIcon: Icons.access_time,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: int.tryParse(horaCtrl.text.split(":")[0]) ?? 12,
                            minute: int.tryParse(horaCtrl.text.split(":")[1]) ?? 0,
                          ),
                        );
                        if (picked != null) {
                          horaCtrl.text =
                              "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GrupoSelector(
                grupoSeleccionado: grupoSeleccionado,
                onGrupoChanged: (grupo) {
                  setModalState(() {
                    grupoSeleccionado = grupo;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("¿Es prioridad?"),
                  Checkbox(
                    value: prioridad,
                    onChanged: (v) => setModalState(() => prioridad = v ?? false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  "Guardar cambios",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  final nuevaFechaHora = DateTime.tryParse(
                    '${fechaCtrl.text} ${horaCtrl.text}',
                  );
                  if (nuevaFechaHora == null ||
                      nuevaFechaHora.isBefore(DateTime.now())) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "La fecha y hora deben ser válidas y futuras",
                        ),
                      ),
                    );
                    return;
                  }

                  if (evento.notificationId != null) {
                    await notificationService.cancelarNotificacion(
                      evento.notificationId!,
                    );
                  }

                  final nuevoId = notificationService.generarNotificationId();
                  await notificationService.programarNotificacion(
                    fechaHora: nuevaFechaHora,
                    titulo: nombreCtrl.text,
                    descripcion: descCtrl.text,
                    id: nuevoId,
                  );

                  await firestoreService.actualizarEvento(evento.id, {
                    "nombreEvento": nombreCtrl.text,
                    "descripcion": descCtrl.text,
                    "fecha": fechaCtrl.text,
                    "hora": horaCtrl.text,
                    "grupo": grupoSeleccionado ?? '',
                    "prioridad": prioridad,
                    "fechaHora": nuevaFechaHora,
                    "notificationId": nuevoId,
                  });

                  Navigator.pop(context);
                  onSaved();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  );
}
