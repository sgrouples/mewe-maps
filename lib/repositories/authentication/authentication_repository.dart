import 'package:mewe_maps/services/http/mewe_service.dart';
import 'package:mewe_maps/services/http/model/challenges_response.dart';
import 'package:mewe_maps/services/http/model/login_with_password_response.dart';

abstract class AuthenticationRepository {
  Future<ChallengesResponse> getChallenges();

  Future<LoginWithPasswordResponse> loginByEmail(String email, String password, String? challenge, String? challengeToken);

  Future<LoginWithPasswordResponse> loginByNumber(String phoneNumber, String password, String? challenge, String? challengeToken);
}

class MeWeAuthenticationRepository implements AuthenticationRepository {
  MeWeAuthenticationRepository(this._meWeService);

  final MeWeService _meWeService;

  @override
  Future<ChallengesResponse> getChallenges() {
    return _meWeService.getChallenges();
  }

  @override
  Future<LoginWithPasswordResponse> loginByEmail(String email, String password, String? challenge, String? challengeToken) {
    if (challenge != null && challengeToken != null) {
      return _meWeService.loginByEmailWithChallenge(email, password, challenge, challengeToken);
    } else {
      return _meWeService.loginByEmail(email, password);
    }
  }

  @override
  Future<LoginWithPasswordResponse> loginByNumber(String phoneNumber, String password, String? challenge, String? challengeToken) {
    if (challenge != null && challengeToken != null) {
      return _meWeService.loginByNumberWithChallenge(phoneNumber, password, challenge, challengeToken);
    } else {
      return _meWeService.loginByNumber(phoneNumber, password);
    }
  }
}
