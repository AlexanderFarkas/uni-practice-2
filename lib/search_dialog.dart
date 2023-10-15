import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:beholder_form/beholder_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_practice_2/explorer_screen_vm.dart';
import 'package:uni_practice_2/search_dialog_vm.dart';
import 'package:path/path.dart' as path;

class SearchDialog extends StatelessWidget {
  final ExplorerScreenVm explorerScreenVm;
  const SearchDialog({super.key, required this.explorerScreenVm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Provider(
          create: (BuildContext context) => SearchDialogVm(explorerScreenVm),
          builder: (context, _) {
            final vm = context.watch<SearchDialogVm>();
            return Column(
              children: [
                FieldObserver(
                  field: vm.search,
                  builder: (context, watch, controller) => SearchBar(controller: controller),
                ),
                Expanded(
                  child: Observer(
                    builder: (context, watch) => switch (watch(vm.searchResult)) {
                      Loading() => const Center(child: CircularProgressIndicator()),
                      Failure(:var error) => Center(child: Text("$error")),
                      Success(value: final entities) => ListView.builder(
                          itemCount: entities.length,
                          itemBuilder: (context, index) {
                            final entity = entities[index];
                            return ListTile(
                              onTap: () {
                                vm.selectEntity(entity);
                                Navigator.of(context).pop();
                              },
                              title: Text(vm.relativePathTo(entity)),
                            );
                          },
                        ),
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
