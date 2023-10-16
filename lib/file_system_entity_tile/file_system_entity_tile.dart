import 'dart:io';

import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:beholder_form/beholder_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:uni_practice_2/explorer_screen/explorer_screen_vm.dart';

import 'file_system_entity_tile_vm.dart';

class FileSystemEntityTile extends StatefulWidget {
  const FileSystemEntityTile({super.key, required this.entity});

  final FileSystemEntity entity;

  @override
  State<FileSystemEntityTile> createState() => _FileSystemEntityTileState();
}

class _FileSystemEntityTileState extends State<FileSystemEntityTile> {
  final tileFocus = FocusNode();

  bool isHovered = false;
  DateTime? tapTimestamp;
  Disposer? disposeSelectedEntityListener;

  @override
  void initState() {
    disposeSelectedEntityListener =
        context.read<ExplorerScreenVm>().selectedEntity.listen((_, value) {
      if (value?.path == widget.entity.path) {
        tileFocus.requestFocus();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    disposeSelectedEntityListener?.call();
    tileFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      key: ValueKey(widget.entity.path),
      create: (BuildContext context) => FileSystemEntityTileVm(
        explorerScreenVm: context.read<ExplorerScreenVm>(),
        entity: widget.entity,
      ),
      dispose: (_, vm) => vm.dispose(),
      child: Observer(
        builder: (context, watch) {
          final vm = context.watch<FileSystemEntityTileVm>();
          final isSelected = watch(vm.isSelected);
          return CallbackShortcuts(
            bindings: {
              if (isSelected)
                const SingleActivator(LogicalKeyboardKey.enter): () => vm.isEditing.value = true,
            },
            child: MouseRegion(
              onEnter: (event) {
                setState(() {
                  isHovered = true;
                });
              },
              onExit: (event) {
                setState(() {
                  isHovered = false;
                });
              },
              child: Draggable(
                data: widget.entity,
                feedback: AbsorbPointer(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.antiAlias,
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Opacity(
                      opacity: 0.95,
                      child: Material(child: _ListTile(entity: widget.entity)),
                    ),
                  ),
                ),
                child: DragTarget<FileSystemEntity>(
                  onWillAccept: (entity) {
                    if (widget.entity is! Directory) return false;
                    return entity?.path != widget.entity.path;
                  },
                  onAccept: (entity) => vm.move(entity),
                  builder: (context, candidates, __) => _ListTile(
                    onTap: _onTap,
                    entity: widget.entity,
                    focusNode: tileFocus,
                    isSelected: isSelected,
                    isHovered: isHovered,
                    isEditing: watch(vm.isEditing),
                    isDraggedOver: candidates.isNotEmpty,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTap() {
    final viewModel = context.read<ExplorerScreenVm>();

    final isDoubleClickTimeframeElapsed = tapTimestamp == null ||
        tapTimestamp!.difference(DateTime.timestamp()).inMilliseconds.abs() > 500;

    tileFocus.requestFocus();
    if (isDoubleClickTimeframeElapsed) {
      tapTimestamp = DateTime.timestamp();
      viewModel.selectEntity(widget.entity);
    } else {
      viewModel.tryOpenEntity(widget.entity);
    }
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    super.key,
    this.focusNode,
    this.isSelected = false,
    this.isEditing = false,
    this.isHovered = false,
    this.isDraggedOver = false,
    required this.entity,
    this.onTap,
  });

  final FileSystemEntity entity;
  final FocusNode? focusNode;
  final bool isSelected;
  final bool isEditing;
  final bool isHovered;
  final bool isDraggedOver;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      focusNode: focusNode,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      selected: isSelected,
      tileColor: isDraggedOver ? Colors.grey.withOpacity(0.2) : null,
      selectedTileColor: Colors.grey.withOpacity(0.2),
      leading: entity is Directory ? const Icon(Icons.folder) : null,
      title: isEditing ? _EditNameTextField() : Text(path.basename(entity.path)),
      trailing: isHovered
          ? IconButton(
              icon: const Icon(Icons.delete_forever_sharp),
              onPressed: () => context.read<FileSystemEntityTileVm>().delete(),
            )
          : null,
    );
  }
}

class _EditNameTextField extends StatefulWidget {
  @override
  State<_EditNameTextField> createState() => _EditNameTextFieldState();
}

class _EditNameTextFieldState extends State<_EditNameTextField> {
  final focusNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FileSystemEntityTileVm>();
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => vm.isEditing.value = false,
        const SingleActivator(LogicalKeyboardKey.enter): () => vm.submitEdit(),
      },
      child: FieldObserver(
        field: vm.name,
        builder: (context, watch, controller) => Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              vm.isEditing.value = false;
            }
          },
          canRequestFocus: false,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 4),
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }
}
