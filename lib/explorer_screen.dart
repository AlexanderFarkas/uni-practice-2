import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uni_practice_2/create_entity_dialog.dart';
import 'package:uni_practice_2/explorer_screen_vm.dart';
import 'package:uni_practice_2/file_system_entity_tile.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExplorerScreenVm>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButton(onPressed: viewModel.goBack),
                  Expanded(
                    child: Observer(
                      builder: (context, watch) => Text(
                        basename(watch(viewModel.currentDirectory).path),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => CreateEntityDialog(
                            type: CreateEntityDialogType.directory,
                            onCreated: (name) => viewModel.createDirectory(name),
                          ),
                        ),
                        icon: const Icon(Icons.create_new_folder),
                      ),
                      IconButton(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => CreateEntityDialog(
                            type: CreateEntityDialogType.file,
                            onCreated: (name) => viewModel.createFile(name),
                          ),
                        ),
                        icon: const Icon(Icons.file_copy_rounded),
                      )
                    ],
                  )
                ],
              ),
              Expanded(
                child: Observer(builder: (context, watch) {
                  final fileSystemEntities = watch(viewModel.directoryContent);
                  return switch (fileSystemEntities) {
                    Success(value: final fileSystemEntities) => ListView.builder(
                        itemCount: fileSystemEntities.length,
                        itemBuilder: (context, index) => FileSystemEntityTile(
                          entity: fileSystemEntities[index],
                        ),
                      ),
                    Failure(:final error) => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(width: 400),
                          child: Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  };
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
