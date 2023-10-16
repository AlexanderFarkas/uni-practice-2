import 'dart:io';

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uni_practice_2/utils.dart';

class ExplorerScreenVm extends ViewModel {
  ExplorerScreenVm() {
    refresh();
  }

  late final currentDirectory = state(Directory.current)
    ..listenSync((previous, next) => selectedEntity.value = null)
    ..listen((previous, next) => refresh());
  late final directoryContent = state<Result<List<FileSystemEntity>>>(const Success([]));
  late final selectedEntity = state<FileSystemEntity?>(null);

  void selectEntity(FileSystemEntity? entity) => selectedEntity.value = entity;
  void move(FileSystemEntity entity, FileSystemEntity target) {
    if (target is! Directory) return;
    entity.renameSync(
      path.join(
        target.path,
        path.basename(entity.path),
      ),
    );

    refresh();
  }

  void tryOpenEntity(FileSystemEntity entity) {
    if (entity is Directory && entity.path == selectedEntity.value?.path) {
      currentDirectory.value = entity;
    }
  }

  void goBack() {
    currentDirectory.value = currentDirectory.value.parent;
  }

  void deleteEntity(FileSystemEntity entity) {
    entity.delete();
  }

  void createFile(String name) {
    final entity = File(path.join(currentDirectory.value.path, name));
    entity.createSync();
    refresh();
  }

  void createDirectory(String name) {
    final entity = Directory(path.join(currentDirectory.value.path, name));
    entity.createSync();
    refresh();
  }

  void _loadContents(Directory directory) {
    try {
      final items = directory.listSync().where((element) => element is! Link).toList();
      sortFileSystemEntities(items);
      directoryContent.value = Success(items);
    } on PathAccessException catch (e, s) {
      directoryContent.value = Failure(e, stackTrace: s);
    }
  }

  void refresh() {
    _loadContents(currentDirectory.value);
  }
}
