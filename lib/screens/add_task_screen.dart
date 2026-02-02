import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/date_formatter.dart';
import '../utils/dialog_helper.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/grupo_selector.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  bool _isPriority = false;
  String? _grupoSeleccionado;

  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateCtrl.text = DateFormatter.formatearFecha(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      _timeCtrl.text = DateFormatter.formatearHora(picked);
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final eventDate = DateTime.parse(_dateCtrl.text);
    final timeParts = _timeCtrl.text.split(':');
    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    if (eventDateTime.isBefore(now)) {
      if (mounted) {
        DialogHelper.mostrarError(
          context,
          "Error",
          "La fecha y hora deben ser futuras",
        );
      }
      return;
    }

    final idNotificacion = _notificationService.generarNotificationId();

    try {
      await _firestoreService.crearEvento({
        "nombreEvento": _nameCtrl.text,
        "descripcion": _descCtrl.text,
        "fecha": _dateCtrl.text,
        "hora": _timeCtrl.text,
        "fechaHora": eventDateTime,
        "prioridad": _isPriority,
        "finalizado": false,
        "grupo": _grupoSeleccionado ?? "",
        "notificationId": idNotificacion,
      });

      await _notificationService.programarNotificacion(
        fechaHora: eventDateTime,
        titulo: _nameCtrl.text,
        descripcion: _descCtrl.text,
        id: idNotificacion,
      );

      if (mounted) {
        DialogHelper.mostrarExito(
          context,
          '¡Éxito!',
          'Tarea registrada exitosamente',
          onOk: () => Navigator.pop(context, true),
        );
      }
    } catch (error) {
      if (mounted) {
        DialogHelper.mostrarError(
          context,
          "Error",
          "Error al guardar: $error",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Añadir nueva tarea")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                controller: _nameCtrl,
                labelText: "Nombre del evento*",
                validator: (value) =>
                    value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _descCtrl,
                labelText: "Descripción (opcional)",
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _dateCtrl,
                      labelText: "Fecha*",
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _timeCtrl,
                      labelText: "Hora*",
                      prefixIcon: Icons.access_time,
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("¿Marcar como prioridad?"),
                  Checkbox(
                    value: _isPriority,
                    onChanged: (v) => setState(() => _isPriority = v ?? false),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GrupoSelector(
                grupoSeleccionado: _grupoSeleccionado,
                onGrupoChanged: (grupo) {
                  setState(() => _grupoSeleccionado = grupo);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "AGREGAR TAREA",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
