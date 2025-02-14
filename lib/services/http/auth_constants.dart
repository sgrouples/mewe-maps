import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthConfig {
  static String meweHost = dotenv.env['MEWE_HOST']!;
  static String meweImageHost = dotenv.env['MEWE_IMAGE_HOST']!;
  static String meweLoginChallengeCaptcha = dotenv.env['MEWE_LOGIN_CHALLENGE_CAPTCHA']!;
}
