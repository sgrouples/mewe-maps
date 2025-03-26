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
import 'package:mewe_maps/repositories/location/sharing_location_repository.dart';

Future<int?> showIntervalModal(BuildContext context, User contact) async {
  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Share for 5 minutes'),
            onTap: () {
              Navigator.of(context).pop(5);
            },
          ),
          ListTile(
            title: const Text('Share for 15 minutes'),
            onTap: () {
              Navigator.of(context).pop(15);
            },
          ),
          ListTile(
            title: const Text('Share for 1 hour'),
            onTap: () {
              Navigator.of(context).pop(60);
            },
          ),
          ListTile(
            title: const Text('Share for 3 hours'),
            onTap: () {
              Navigator.of(context).pop(180);
            },
          ),
          ListTile(
            title: const Text('Share until I stop'),
            onTap: () {
              Navigator.of(context).pop(TIME_INTERVAL_FOREVER);
            },
          ),
        ],
      );
    },
  );
}
