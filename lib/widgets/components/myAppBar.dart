import 'package:flutter/material.dart';

import '../../models/userModel.dart';
import '../../screens/profilePage.dart';
import '../../services/authService.dart';
import '../../services/databaseService.dart';

class MyAppBar extends AppBar {
  MyAppBar({
    super.key,
    required UserModel user,
    required BuildContext context,
    required DatabaseService databaseService,
    required AuthService authService,
    required VoidCallback rebuildAppBar,
  }) : super(
          title: Text(
            'Simply Travel',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>  ProfilePage(
                              userId: user.id,
                              isCurrentUser: true,
                        databaseService: databaseService,
                        authService: authService,
                            ),
                      ),
                ).then((_) {
                  rebuildAppBar();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2), // border width
                decoration: const BoxDecoration(
                  color: Colors.white, // border color
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  key: const Key('profileButton'),
                  radius: 18,
                  backgroundImage:
                      AssetImage(user.profilePic ?? 'assets/profile.png'),
                  // If using local assets: AssetImage(profileImageUrl)
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        );
}
