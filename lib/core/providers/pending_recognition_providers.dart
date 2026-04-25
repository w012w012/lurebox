import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lurebox/core/di/di.dart';
import 'package:lurebox/core/models/fish_catch.dart';

/// 待识别鱼种计数 Provider
final pendingRecognitionCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(fishCatchRepositoryProvider);
  return repository.getPendingRecognitionCount();
});

/// 待识别鱼种记录列表 Provider
final pendingRecognitionCatchesProvider =
    FutureProvider<List<FishCatch>>((ref) async {
  final repository = ref.watch(fishCatchRepositoryProvider);
  return repository.getPendingRecognitionCatches();
});
