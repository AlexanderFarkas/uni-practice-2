import 'package:flutter/material.dart';

enum CreateEntityDialogType { file, directory }

class CreateEntityDialog extends StatefulWidget {
  final CreateEntityDialogType type;
  final void Function(String name) onCreated;
  const CreateEntityDialog({
    super.key,
    required this.type,
    required this.onCreated,
  });

  @override
  State<CreateEntityDialog> createState() => _CreateEntityDialogState();
}

class _CreateEntityDialogState extends State<CreateEntityDialog> {
  late final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  label: Text(
                      "Имя ${CreateEntityDialogType.file == widget.type ? "файла" : "папки"}")),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                try {
                  widget.onCreated(controller.text);
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Создать"),
            )
          ],
        ),
      ),
    );
  }
}
