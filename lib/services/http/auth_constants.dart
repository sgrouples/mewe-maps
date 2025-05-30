// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthConfig {
  static String meweHost = dotenv.env['MEWE_HOST']!;
  static String meweImageHost = dotenv.env['MEWE_IMAGE_HOST']!;
  static String meweAppId = dotenv.env['MEWE_APP_ID']!;
  static String meweApiKey = dotenv.env['MEWE_APP_API_KEY']!;
}
