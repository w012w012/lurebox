import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lurebox/core/services/app_logger.dart';
import 'package:lurebox/core/services/share_template.dart';
import 'package:share_plus/share_plus.dart';

/// 分享卡片服务 - Widget 捕获与社交分享
///
/// 提供将 Flutter UI 元素转换为图片并进行分享的功能：
/// - Widget 捕获：使用 RenderRepaintBoundary 将 Widget 渲染为 PNG 图片
/// - 图片分享：支持带文字说明的图片分享到各类社交平台
/// - 文本分享：纯文本分享功能
/// - 卡片生成：根据 [ShareCardConfig] 配置生成完整的分享内容
///
/// 使用 [share_plus] 包实现跨平台分享功能。

class ShareCardService {
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final renderObj = key.currentContext?.findRenderObject();
      if (renderObj is! RenderRepaintBoundary) return null;
      final boundary = renderObj;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      AppLogger.e('ShareCardService', 'Error capturing widget', e);
      return null;
    }
  }

  static Future<void> shareImage(Uint8List imageBytes, {String? text}) async {
    await Share.shareXFiles([
      XFile.fromData(
        imageBytes,
        mimeType: 'image/png',
        name: 'lurebox_share.png',
      ),
    ], text: text,);
  }

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  static String generateShareText(ShareCardConfig config) {
    final buffer = StringBuffer();

    if (config.showHashtags) {
      if (config.customHashtags.isNotEmpty) {
        buffer.writeln(config.customHashtags.join(' '));
      } else {
        buffer.writeln(ShareCardConfig.defaultHashtags.join(' '));
      }
    }

    if (config.showStats && config.statsData != null) {
      final stats = config.statsData!;
      if (stats.containsKey('totalCatches')) {
        buffer.writeln('Total Catches: ${stats['totalCatches']}');
      }
      if (stats.containsKey('speciesCount')) {
        buffer.writeln('Species: ${stats['speciesCount']}');
      }
    }

    return buffer.toString().trim();
  }

  static Future<Uint8List?> generateShareCard({
    required GlobalKey repaintBoundaryKey,
  }) async {
    final renderObj =
        repaintBoundaryKey.currentContext?.findRenderObject();
    if (renderObj is! RenderRepaintBoundary) return null;
    final boundary = renderObj;

    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
