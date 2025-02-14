import 'package:mewe_maps/models/user.dart';
import 'package:mewe_maps/services/http/mewe_service.dart';
import 'package:synchronized/synchronized.dart';

abstract class ContactsRepository {
  Future<List<User>> getContacts();
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
          final response = await (nextPageUrl == null ? _userService.getFollowed() : _userService.getFollowedNextPage(nextPageUrl));

          _cachedContacts!.addAll(
            response.list.where((it) => it.follower == true).map((it) => it.user).toList(),
          );

          nextPageUrl = response.halLinks?.nextPage?.href;
        } while (nextPageUrl != null);
      }
      return _cachedContacts!;
    });
  }
}
