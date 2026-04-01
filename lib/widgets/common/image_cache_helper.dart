import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheHelper {
  // 动态缓存大小：根据设备内存调整
  static final LRUMap<String, ImageProvider> _memoryCache = LRUMap(
    maxSize: _calculateCacheSize(),
  );
  static final Map<String, ImageProvider> _thumbnailCache = {};

  // 根据设备内存动态计算缓存大小
  static int _calculateCacheSize() {
    // 默认缓存大小
    int cacheSize = 50;

    // 在Web平台上使用较小的缓存
    if (kIsWeb) {
      cacheSize = 30;
    }

    return cacheSize;
  }

  static int get maxCacheSize => _memoryCache.maxSize;
  static set maxCacheSize(int size) => _memoryCache.maxSize = size;

  static ImageProvider getThumbnailProvider(
    String? imagePath, {
    int? width,
    int? height,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/images/placeholder.png');
    }
    return FileImage(File(imagePath));
  }

  static ImageProvider getCachedThumbnailProvider(
    String? imagePath, {
    int? width,
    int? height,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/images/placeholder.png');
    }

    final key = _getCacheKey(imagePath, width, height);
    final cached = _memoryCache.get(key);
    if (cached != null) return cached;

    final file = File(imagePath);
    ImageProvider provider;
    if (width != null && height != null) {
      provider = ResizeImage(FileImage(file), width: width, height: height);
    } else if (width != null) {
      provider = ResizeImage(FileImage(file), width: width);
    } else if (height != null) {
      provider = ResizeImage(FileImage(file), height: height);
    } else {
      provider = FileImage(file);
    }
    _memoryCache.put(key, provider);
    return provider;
  }

  static String _getCacheKey(String path, int? width, int? height) {
    return '${path}_${width}x$height';
  }

  static Future<void> precacheThumbnail(
    BuildContext context,
    String? imagePath, {
    int? width,
    int? height,
  }) async {
    if (imagePath == null || imagePath.isEmpty) return;

    final key = _getCacheKey(imagePath, width, height);
    if (_memoryCache.containsKey(key)) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        ImageProvider provider;
        if (width != null && height != null) {
          provider = ResizeImage(FileImage(file), width: width, height: height);
        } else if (width != null) {
          provider = ResizeImage(FileImage(file), width: width);
        } else if (height != null) {
          provider = ResizeImage(FileImage(file), height: height);
        } else {
          provider = FileImage(file);
        }
        await precacheImage(provider, context);
        _memoryCache.put(key, provider);
      }
    } catch (e) {
      debugPrint('Precache failed for $imagePath: $e');
    }
  }

  static Future<void> precacheList(
    BuildContext context,
    List<String?> imagePaths, {
    int? width,
    int? height,
  }) async {
    final futures = imagePaths
        .where((path) => path != null && path.isNotEmpty)
        .map(
          (path) =>
              precacheThumbnail(context, path, width: width, height: height),
        );
    await Future.wait(futures);
  }

  static void removeFromCache(String imagePath) {
    _memoryCache.remove(imagePath);
    _thumbnailCache.removeWhere((key, _) => key.startsWith(imagePath));
  }

  static void clearCache() {
    _memoryCache.clear();
    _thumbnailCache.clear();
  }

  static void clearThumbnailCache() {
    _thumbnailCache.clear();
  }

  static int get cacheSize => _memoryCache.length;

  /// 清理未使用的图像文件
  ///
  /// [daysToKeep] 保留最近多少天的文件
  /// 返回删除的文件数量
  static Future<int> cleanupUnusedImages({int daysToKeep = 30}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/images');

      if (!await imageDir.exists()) {
        return 0;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      int deletedCount = 0;

      await for (final entity in imageDir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            // 检查文件是否在缓存中使用
            final key = _getCacheKey(entity.path, null, null);
            if (!_memoryCache.containsKey(key)) {
              await entity.delete();
              deletedCount++;
              debugPrint('Deleted unused image: ${entity.path}');
            }
          }
        }
      }

      debugPrint('Cleaned up $deletedCount unused images');
      return deletedCount;
    } catch (e) {
      debugPrint('Image cleanup failed: $e');
      return 0;
    }
  }

  /// 预加载图像列表
  ///
  /// [context] 构建上下文
  /// [imagePaths] 图像路径列表
  /// [width] 预加载宽度
  /// [height] 预加载高度
  static Future<void> preloadImages(
    BuildContext context,
    List<String?> imagePaths, {
    int? width,
    int? height,
  }) async {
    final futures = <Future<void>>[];

    for (final path in imagePaths) {
      if (path != null && path.isNotEmpty) {
        final key = _getCacheKey(path, width, height);
        if (!_memoryCache.containsKey(key)) {
          futures.add(
              precacheThumbnail(context, path, width: width, height: height));
        }
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }
}

class LRUMap<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  LRUMap({int maxSize = 50}) : _maxSize = maxSize;

  int get maxSize => _maxSize;
  set maxSize(int size) {
    while (_map.length > size) {
      _map.remove(_map.keys.first);
    }
  }

  V? get(K key) {
    if (!_map.containsKey(key)) return null;
    final value = _map.remove(key)!;
    _map[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= _maxSize) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void remove(K key) => _map.remove(key);

  void clear() => _map.clear();

  int get length => _map.length;
}

class CachedNetworkImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;

  const CachedNetworkImage({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return Image(
      image: ImageCacheHelper.getCachedThumbnailProvider(
        imagePath,
        width: cacheWidth,
        height: cacheHeight,
      ),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return frame != null
            ? AnimatedOpacity(
                opacity: frame == 0 ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: child,
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: (width ?? 50) / 2,
      ),
    );
  }
}
