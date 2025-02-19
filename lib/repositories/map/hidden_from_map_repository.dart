// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:rxdart/rxdart.dart';

abstract class HiddenFromMapRepository {
  void setUserHidden(String userId, bool isHidden);

  Stream<List<String>> observeHiddenUsers();
}

class MemoryHiddenFromMapRepository implements HiddenFromMapRepository {
  final _hiddenUserIds = BehaviorSubject<List<String>>.seeded([]);

  @override
  void setUserHidden(String userId, bool isHidden) {
    final hiddenUserIds = _hiddenUserIds.value;
    if (isHidden) {
      hiddenUserIds.add(userId);
    } else {
      hiddenUserIds.remove(userId);
    }
    _hiddenUserIds.add(hiddenUserIds);
  }

  @override
  Stream<List<String>> observeHiddenUsers() {
    return _hiddenUserIds.stream;
  }
}
