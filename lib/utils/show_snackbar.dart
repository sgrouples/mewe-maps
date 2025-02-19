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

void showSnackBar(BuildContext context, String message,
    {bool longDuration = false}) {
  final snack = SnackBar(
    content: Center(
        child: Text(message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white))),
    duration: longDuration
        ? const Duration(milliseconds: 5000)
        : const Duration(milliseconds: 2000),
    backgroundColor: Colors.green[900],
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
    dismissDirection: DismissDirection.horizontal,
  );
  ScaffoldMessenger.of(context).showSnackBar(snack);
}
