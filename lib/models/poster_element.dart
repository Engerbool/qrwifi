import 'package:flutter/material.dart';

/// Type of poster element
enum ElementType { qrCode, title, message, ssidPassword, signature, wifiIcon }

/// Represents an editable element on the poster canvas
class PosterElement {
  final String id;
  final ElementType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final int zIndex;
  final Color? textColor;
  final Color? backgroundColor;
  final String? fontFamily;
  final double? fontSize;
  final String? content;

  const PosterElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.zIndex = 0,
    this.textColor,
    this.backgroundColor,
    this.fontFamily,
    this.fontSize,
    this.content,
  });

  /// Creates a copy of this element with the given fields replaced
  PosterElement copyWith({
    String? id,
    ElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    int? zIndex,
    Color? textColor,
    Color? backgroundColor,
    String? fontFamily,
    double? fontSize,
    String? content,
  }) {
    return PosterElement(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      zIndex: zIndex ?? this.zIndex,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      content: content ?? this.content,
    );
  }

  /// Returns the bounding rectangle of this element
  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  /// Returns the center point of this element
  Offset get center => Offset(x + width / 2, y + height / 2);

  /// Whether this element should maintain aspect ratio when resizing
  bool get maintainAspectRatio => type == ElementType.qrCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PosterElement &&
        other.id == id &&
        other.type == type &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        other.zIndex == zIndex &&
        other.textColor == textColor &&
        other.backgroundColor == backgroundColor &&
        other.fontFamily == fontFamily &&
        other.fontSize == fontSize &&
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      type,
      x,
      y,
      width,
      height,
      zIndex,
      textColor,
      backgroundColor,
      fontFamily,
      fontSize,
      content,
    );
  }

  @override
  String toString() {
    return 'PosterElement(id: $id, type: $type, x: $x, y: $y, '
        'width: $width, height: $height, zIndex: $zIndex)';
  }
}
