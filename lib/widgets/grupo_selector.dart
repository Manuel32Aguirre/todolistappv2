import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class GrupoSelector extends StatefulWidget {
  final String? grupoSeleccionado;
  final Function(String?) onGrupoChanged;

  const GrupoSelector({
    super.key,
    this.grupoSeleccionado,
    required this.onGrupoChanged,
  });

  @override
  State<GrupoSelector> createState() => _GrupoSelectorState();
}

class _GrupoSelectorState extends State<GrupoSelector> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nuevoGrupoCtrl = TextEditingController();
  List<String> _gruposDisponibles = [];

  @override
  void initState() {
    super.initState();
    _fetchGrupos();
  }

  @override
  void dispose() {
    _nuevoGrupoCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchGrupos() async {
    final grupos = await _firestoreService.getGruposDisponibles();
    setState(() {
      _gruposDisponibles = grupos;
      if (widget.grupoSeleccionado != null && 
          widget.grupoSeleccionado!.isNotEmpty &&
          !_gruposDisponibles.contains(widget.grupoSeleccionado)) {
        _gruposDisponibles.add(widget.grupoSeleccionado!);
      }
    });
  }

  void _mostrarDialogoNuevoGrupo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo grupo'),
        content: TextField(
          controller: _nuevoGrupoCtrl,
          decoration: const InputDecoration(hintText: 'Nombre del grupo'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final nuevo = _nuevoGrupoCtrl.text.trim();
              if (nuevo.isNotEmpty) {
                setState(() {
                  _gruposDisponibles.add(nuevo);
                });
                widget.onGrupoChanged(nuevo);
                _nuevoGrupoCtrl.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Crear'),
          ),
          TextButton(
            onPressed: () {
              _nuevoGrupoCtrl.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final valorValido = widget.grupoSeleccionado != null &&
            widget.grupoSeleccionado!.isNotEmpty &&
            (_gruposDisponibles.contains(widget.grupoSeleccionado) ||
                widget.grupoSeleccionado == '_nuevo_')
        ? widget.grupoSeleccionado
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Grupo (opcional)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButtonFormField<String>(
          value: valorValido,
          items: [
            ..._gruposDisponibles.map(
              (g) => DropdownMenuItem(value: g, child: Text(g)),
            ),
            const DropdownMenuItem(
              value: '_nuevo_',
              child: Text('➕ Crear nuevo grupo'),
            ),
          ],
          onChanged: (val) {
            if (val == '_nuevo_') {
              _mostrarDialogoNuevoGrupo();
            } else {
              widget.onGrupoChanged(val);
            }
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
