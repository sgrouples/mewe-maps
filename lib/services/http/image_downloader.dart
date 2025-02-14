import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
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
        final response = await http.get(Uri.parse(imageUrl));
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
