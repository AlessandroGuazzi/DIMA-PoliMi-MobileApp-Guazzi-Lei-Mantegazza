import 'package:flutter/material.dart';

class AvatarSelectionPage extends StatelessWidget {
  final List<String> avatarPaths;
  final Function(String) onAvatarSelected;

  const AvatarSelectionPage({
    super.key,
    required this.avatarPaths,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleziona il tuo avatar")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: avatarPaths.length,
        itemBuilder: (context, index) {
          final path = avatarPaths[index];
          return GestureDetector(
            onTap: () {
              onAvatarSelected(path);
            },
            child: Image.asset(path),
          );
        },
      ),
    );
  }
}