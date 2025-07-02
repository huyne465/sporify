import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheConfig {
  static CacheManager get imageCacheManager => CacheManager(
    Config(
      'playlist_images',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: 'playlist_cache.db'),
      fileService: HttpFileService(),
    ),
  );
}
