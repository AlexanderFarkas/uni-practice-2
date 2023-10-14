import 'dart:io';

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

class ExplorerScreenVm extends ViewModel {
  ExplorerScreenVm() {
    final subscription = currentDirectory //
        .asStream()
        .startWith(currentDirectory.value)
        .listen((directory) => _loadContents(directory));

    disposers.add(subscription.cancel);
  }

  late final currentDirectory = state(Directory.current)
    ..listenSync((previous, next) => selectedEntity.value = null);
  late final directoryContent = state<Result<List<FileSystemEntity>>>(const Success([]));
  late final selectedEntity = state<FileSystemEntity?>(null);

  void selectEntity(FileSystemEntity? entity) => selectedEntity.value = entity;

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
      _sortFileSystemEntities(items);
      directoryContent.value = Success(items);
    } on PathAccessException catch (e, s) {
      directoryContent.value = Failure(e, stackTrace: s);
    }
  }

  void refresh() {
    _loadContents(currentDirectory.value);
  }
}

void _sortFileSystemEntities(List<FileSystemEntity> entities) {
  entities.sort((entity1, entity2) {
    if (entity1 is Directory) {
      if (entity2 is Directory) {
        return entity1.path.compareTo(entity2.path);
      } else {
        return -1;
      }
    } else if (entity1 is File) {
      if (entity2 is File) {
        return entity1.path.compareTo(entity2.path);
      } else {
        return 1;
      }
    } else {
      return 1;
    }
  });
}
