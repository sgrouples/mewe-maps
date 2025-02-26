// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/services/http/mewe_service.dart';
import 'package:synchronized/synchronized.dart';

abstract class ContactsRepository {
  Future<List<User>> getContacts({bool forceRefresh = false});
}

class MeWeContactsRepository implements ContactsRepository {
  late final MeWeService _userService;
  final _lock = Lock();

  List<User>? _cachedContacts;

  MeWeContactsRepository(this._userService);

  @override
  Future<List<User>> getContacts({bool forceRefresh = false}) async {
    return _lock.synchronized(() async {
      if (_cachedContacts == null || forceRefresh) {
        _cachedContacts = [];
        String? nextPageUrl;

        do {
          final response = await (nextPageUrl == null
              ? _userService.getFollowed()
              : _userService.getFollowedNextPage(nextPageUrl));

          _cachedContacts!.addAll(
            response.list
                .where((it) => it.follower == true)
                .map((it) => it.user)
                .toList(),
          );

          nextPageUrl = response.halLinks?.nextPage?.href;
        } while (nextPageUrl != null);
      }
      return _cachedContacts!;
    });
  }
}
