import 'package:flutter/material.dart';

/// Resize handle position enum
enum HandlePosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Widget that renders 8 resize handles around an element
class ResizeHandles extends StatelessWidget {
  final double width;
  final double height;
  final double handleSize;
  final void Function(HandlePosition position, Offset delta) onHandleDrag;
  final VoidCallback? onDragEnd;

  /// Minimum touch target size for accessibility (Material Design: 48dp)
  static const double kMinTouchTarget = 48.0;

  const ResizeHandles({
    super.key,
    required this.width,
    required this.height,
    required this.onHandleDrag,
    this.onDragEnd,
    this.handleSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    // The parent Stack already has expanded bounds, handles fit within
    final offset = handleSize / 2;

    return Stack(
      children: [
        // Top row
        _buildHandle(HandlePosition.topLeft, 0, 0),
        _buildHandle(
          HandlePosition.topCenter,
          offset + width / 2 - handleSize / 2,
          0,
        ),
        _buildHandle(
          HandlePosition.topRight,
          offset + width - handleSize / 2,
          0,
        ),

        // Middle row
        _buildHandle(
          HandlePosition.centerLeft,
          0,
          offset + height / 2 - handleSize / 2,
        ),
        _buildHandle(
          HandlePosition.centerRight,
          offset + width - handleSize / 2,
          offset + height / 2 - handleSize / 2,
        ),

        // Bottom row
        _buildHandle(
          HandlePosition.bottomLeft,
          0,
          offset + height - handleSize / 2,
        ),
        _buildHandle(
          HandlePosition.bottomCenter,
          offset + width / 2 - handleSize / 2,
          offset + height - handleSize / 2,
        ),
        _buildHandle(
          HandlePosition.bottomRight,
          offset + width - handleSize / 2,
          offset + height - handleSize / 2,
        ),
      ],
    );
  }

  Widget _buildHandle(HandlePosition position, double left, double top) {
    // Expand touch area to meet accessibility guidelines (48dp minimum)
    final touchPadding = (kMinTouchTarget - handleSize) / 2;

    return Positioned(
      left: left - touchPadding,
      top: top - touchPadding,
      child: GestureDetector(
        key: Key('handle-${_positionToString(position)}'),
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onHandleDrag(position, details.delta),
        onPanEnd: (_) => onDragEnd?.call(),
        child: MouseRegion(
          cursor: _getCursor(position),
          child: Container(
            width: kMinTouchTarget,
            height: kMinTouchTarget,
            alignment: Alignment.center,
            // Transparent touch area
            color: Colors.transparent,
            child: Container(
              width: handleSize,
              height: handleSize,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _positionToString(HandlePosition position) {
    switch (position) {
      case HandlePosition.topLeft:
        return 'topLeft';
      case HandlePosition.topCenter:
        return 'topCenter';
      case HandlePosition.topRight:
        return 'topRight';
      case HandlePosition.centerLeft:
        return 'centerLeft';
      case HandlePosition.centerRight:
        return 'centerRight';
      case HandlePosition.bottomLeft:
        return 'bottomLeft';
      case HandlePosition.bottomCenter:
        return 'bottomCenter';
      case HandlePosition.bottomRight:
        return 'bottomRight';
    }
  }

  MouseCursor _getCursor(HandlePosition position) {
    switch (position) {
      case HandlePosition.topLeft:
      case HandlePosition.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandlePosition.topRight:
      case HandlePosition.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case HandlePosition.topCenter:
      case HandlePosition.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case HandlePosition.centerLeft:
      case HandlePosition.centerRight:
        return SystemMouseCursors.resizeLeftRight;
    }
  }
}

/// Helper extension for handling resize deltas
extension HandlePositionExtension on HandlePosition {
  /// Returns whether this handle affects the X position
  bool get affectsX =>
      this == HandlePosition.topLeft ||
      this == HandlePosition.centerLeft ||
      this == HandlePosition.bottomLeft;

  /// Returns whether this handle affects the Y position
  bool get affectsY =>
      this == HandlePosition.topLeft ||
      this == HandlePosition.topCenter ||
      this == HandlePosition.topRight;

  /// Returns whether this handle affects width
  bool get affectsWidth =>
      this != HandlePosition.topCenter && this != HandlePosition.bottomCenter;

  /// Returns whether this handle affects height
  bool get affectsHeight =>
      this != HandlePosition.centerLeft && this != HandlePosition.centerRight;

  /// Returns whether this is a corner handle (maintains aspect ratio for QR)
  bool get isCorner =>
      this == HandlePosition.topLeft ||
      this == HandlePosition.topRight ||
      this == HandlePosition.bottomLeft ||
      this == HandlePosition.bottomRight;
}
