// Copyright MeWe 2025.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mewe_maps/services/http/timeout_constants.dart';
import 'package:mewe_maps/utils/logger.dart';
import 'package:synchronized/synchronized.dart';

const _TAG = 'ImageDownloader';

class ImageDownloader {
  final Map<String, MemoryImage> _imageCache = {};
  final Lock _cacheLock = Lock();

  Future<MemoryImage?> downloadImage(String imageUrl) async {
    return await _cacheLock.synchronized(() async {
      // Check if the image is already in the cache
      if (_imageCache.containsKey(imageUrl)) {
        return _imageCache[imageUrl]!;
      }

      // Download the image and add it to the cache
      try {
        final response = await http.get(Uri.parse(imageUrl)).timeout(Timeouts.receiveTimeout);

        if (response.statusCode == 200) {
          final Uint8List imageData = response.bodyBytes;
          final MemoryImage image = MemoryImage(imageData);

          _imageCache[imageUrl] = image; // Cache the image

          return image;
        } else {
          Logger.log(_TAG, 'Failed to download image: ${response.statusCode}');
        }
      } catch (e) {
        Logger.log(_TAG, 'Error downloading image: $e');
      }

      return null;
    });
  }
}
