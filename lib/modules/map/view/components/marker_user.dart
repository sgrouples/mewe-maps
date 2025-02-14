import 'package:flutter/material.dart';
import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/modules/common/view/components/user_avatar.dart';

class MarkerUser extends StatelessWidget {
  final User user;
  final ImageProvider? customImage;

  const MarkerUser({
    super.key,
    required this.user,
    this.customImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(
          user: user,
          customImage: customImage,
        ),
        Text(
          user.isMe() ? "${user.name} (You)" : user.name,
          style: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }
}
