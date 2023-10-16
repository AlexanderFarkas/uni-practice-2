import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'explorer_screen/explorer_screen.dart';
import 'explorer_screen/explorer_screen_vm.dart';

void main() {
  runApp(const FileExplorerApplication());
}

class FileExplorerApplication extends StatelessWidget {
  const FileExplorerApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ExplorerScreenVm(),
      dispose: (_, vm) => vm.dispose(),
      child: MaterialApp(
        title: 'Flutter Demo',
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.dark,
        home: const ExplorerScreen(),
      ),
    );
  }
}
