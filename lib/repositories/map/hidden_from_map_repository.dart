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
