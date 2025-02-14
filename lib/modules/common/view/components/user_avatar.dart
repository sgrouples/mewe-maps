import 'package:flutter/material.dart';
import 'package:mewe_maps/models/user.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final ImageProvider? customImage;
  final Color? backgroundColor;
  final double radius;

  const UserAvatar({super.key, required this.user, this.customImage, this.backgroundColor, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    String avatarUrl = user.halLinks.getAvatarUrl();
    return CircleAvatar(
      backgroundImage: customImage ?? NetworkImage(avatarUrl),
      backgroundColor: user.isMe() ? Colors.blue : null,
      radius: radius,
      child: (avatarUrl.isEmpty && customImage == null) ? const Icon(Icons.location_on) : null,
    );
  }
}
