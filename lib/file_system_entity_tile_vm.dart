import 'dart:io';
import 'package:beholder_form/beholder_form.dart';
import 'package:path/path.dart' as path;
import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:uni_practice_2/explorer_screen_vm.dart';

class FileSystemEntityTileVm extends ViewModel with FormMixin {
  FileSystemEntityTileVm({required this.explorerScreenVm, required this.entity});

  final FileSystemEntity entity;
  final ExplorerScreenVm explorerScreenVm;

  late final isSelected = computed(
    (watch) => watch(explorerScreenVm.selectedEntity)?.path == entity.path,
  )..listen((previous, isSelected) {
      if (!isSelected) {
        isEditing.value = false;
      }
    });

  late final name = field<String>(value: path.basename(entity.path));
  late final isEditing = state(false);

  void submitEdit() {
    try {
      final newEntity = entity.renameSync(
        path.join(
          entity.parent.path,
          name.value,
        ),
      );
      name.value = path.basename(newEntity.path);
    } finally {
      isEditing.value = false;
      explorerScreenVm.refresh();
    }
  }
}
