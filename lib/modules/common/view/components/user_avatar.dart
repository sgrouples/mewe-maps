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

class UserAvatar extends StatelessWidget {
  final User? user;
  final ImageProvider? customImage;
  final Color? backgroundColor;
  final double radius;

  const UserAvatar({super.key, required this.user, this.customImage, this.backgroundColor, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    String avatarUrl = user?.halLinks.getAvatarUrl() ?? "";
    double borderWidth = radius * 0.1;
    return Container(
      width: radius * 2 + borderWidth * 2,
      height: radius * 2 + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: borderWidth),
      ),
      child: CircleAvatar(
        backgroundImage: customImage ?? (avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        radius: radius,
        child: (avatarUrl.isEmpty && customImage == null) ? const Icon(Icons.location_on) : null,
      ),
    );
  }
}
