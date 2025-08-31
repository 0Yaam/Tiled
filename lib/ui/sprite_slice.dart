import 'package:flutter/widgets.dart';

/// Hiển thị 1 lát cắt (sourceRect) từ ảnh asset, scale ra size mong muốn.
/// Không cần async ImageStream; dùng ClipRect + Transform đơn giản.
class SpriteSlice extends StatelessWidget {
  final String asset;
  final Rect source;
  final Size displaySize;

  const SpriteSlice({
    super.key,
    required this.asset,
    required this.source,
    this.displaySize = const Size(48, 48),
  });

  @override
  Widget build(BuildContext context) {
    final crop = SizedBox(
      width: source.width,
      height: source.height,
      child: ClipRect(
        child: Transform.translate(
          offset: Offset(-source.left, -source.top),
          child: Image.asset(
            asset,
            gaplessPlayback: true,
            filterQuality: FilterQuality.none, // giữ pixel art sắc nét
          ),
        ),
      ),
    );

    return SizedBox(
      width: displaySize.width,
      height: displaySize.height,
      child: FittedBox(fit: BoxFit.fill, child: crop),
    );
  }
}
