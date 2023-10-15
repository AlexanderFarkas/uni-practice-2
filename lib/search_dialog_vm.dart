import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:beholder_form/beholder_form.dart';
import 'package:uni_practice_2/explorer_screen_vm.dart';
import 'package:uni_practice_2/utils.dart';

class SearchDialogVm extends ViewModel with FormMixin {
  SearchDialogVm(this.explorerScreenVm);

  final ExplorerScreenVm explorerScreenVm;

  late final search = field(value: "") //
    ..listen((previous, next) => _searchBySubstring(next));

  late final searchResult = asyncState<List<FileSystemEntity>>(
    value: const Success([]),
    debounceTime: const Duration(milliseconds: 500),
  );

  void _searchBySubstring(String substring) {
    if (substring.isEmpty) {
      searchResult.value = const Success([]);
      return;
    }

    searchResult.scheduleRefresh((token) async {
      final matched = <FileSystemEntity>[];
      final contentsStream = explorerScreenVm.currentDirectory.value.list(recursive: true);
      await for (final entity in contentsStream) {
        if (token.isCancelled) {
          break;
        }

        if (entity.path.contains(substring) && entity is! Link) {
          matched.add(entity);
        }
      }

      sortFileSystemEntities(matched);
      return matched;
    });
  }

  String relativePathTo(FileSystemEntity entity) {
    return path.relative(
      entity.path,
      from: explorerScreenVm.currentDirectory.value.path,
    );
  }

  void selectEntity(FileSystemEntity entity) {
    switch (entity) {
      case File() && final file:
        explorerScreenVm.currentDirectory.value = file.parent;
      case Directory() && final dir:
        explorerScreenVm.currentDirectory.value = dir;
    }
  }
}
