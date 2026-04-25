import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
