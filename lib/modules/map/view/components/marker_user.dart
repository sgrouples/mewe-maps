// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

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
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
