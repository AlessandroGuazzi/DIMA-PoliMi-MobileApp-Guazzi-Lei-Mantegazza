import 'dart:ui';

import 'package:dima_project/models/userModel.dart';
import 'package:flutter/material.dart';

import '../../utils/screenSize.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel user;

  const UserProfileCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Profile Picture with Border
                    CircleAvatar(
                      radius: ScreenSize.screenHeight(context) * 0.1,
                      backgroundImage: user.profilePic != null
                          ? AssetImage(user.profilePic!)
                          : const AssetImage('assets/profile.png'),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${user.name} ${user.surname}',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '@${user.username}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 16),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}