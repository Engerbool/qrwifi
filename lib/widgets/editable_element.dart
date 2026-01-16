import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poster_element.dart';
import '../providers/poster_provider.dart';
import '../providers/locale_provider.dart';
import '../config/translations.dart';
import 'qr_widget.dart';
import 'font_picker.dart';
import 'resize_handles.dart';

/// Minimum element size in canvas coordinates
const double kMinElementSize = 30.0;

/// Handle size for resize handles
const double kHandleSize = 12.0;

/// Widget that renders an editable poster element with drag and resize support
class EditableElement extends StatefulWidget {
  final PosterElement element;
  final double canvasScale;
  final bool isSelected;

  const EditableElement({
    super.key,
    required this.element,
    required this.canvasScale,
    this.isSelected = false,
  });

  @override
  State<EditableElement> createState() => _EditableElementState();
}

class _EditableElementState extends State<EditableElement> {
  bool _isDragging = false;
  bool _isScaling = false;
  double _initialWidth = 0.0;
  double _initialHeight = 0.0;
  Offset _lastFocalPoint = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PosterProvider>();
    final scaledWidth = widget.element.width * widget.canvasScale;
    final scaledHeight = widget.element.height * widget.canvasScale;

    // When selected, expand bounds to include resize handles
    final handleMargin = widget.isSelected ? kHandleSize / 2 : 0.0;
    final expandedWidth = scaledWidth + (widget.isSelected ? kHandleSize : 0);
    final expandedHeight = scaledHeight + (widget.isSelected ? kHandleSize : 0);

    return Positioned(
      left: widget.element.x * widget.canvasScale - handleMargin,
      top: widget.element.y * widget.canvasScale - handleMargin,
      width: expandedWidth,
      height: expandedHeight,
      child: Stack(
        children: [
          // Main content with gesture handling - positioned inside expanded area
          Positioned(
            left: handleMargin,
            top: handleMargin,
            width: scaledWidth,
            height: scaledHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                provider.selectElement(widget.element.id);
              },
              // Use scale gesture which handles both pan (1 finger) and pinch (2 fingers)
              onScaleStart: (details) => _handleScaleStart(context, details),
              onScaleUpdate: (details) => _handleScaleUpdate(context, details),
              onScaleEnd: (details) => _handleScaleEnd(context, details),
              child: Container(
                decoration: widget.isSelected
                    ? BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: _buildContent(context),
              ),
            ),
          ),
          // Resize handles (only when selected) - now fits within expanded bounds
          if (widget.isSelected)
            ResizeHandles(
              width: scaledWidth,
              height: scaledHeight,
              handleSize: kHandleSize,
              onHandleDrag: (position, delta) =>
                  _handleResize(context, position, delta),
              onDragEnd: () => _handleResizeEnd(context),
            ),
        ],
      ),
    );
  }

  /// Handle scale gesture start - works for both pan (1 finger) and pinch (2 fingers)
  void _handleScaleStart(BuildContext context, ScaleStartDetails details) {
    final provider = context.read<PosterProvider>();
    provider.selectElement(widget.element.id);

    final currentElement = provider.getElementById(widget.element.id);
    if (currentElement == null) return;

    _lastFocalPoint = details.focalPoint;
    _initialWidth = currentElement.width;
    _initialHeight = currentElement.height;

    if (details.pointerCount >= 2) {
      // Pinch gesture
      setState(() {
        _isScaling = true;
        _isDragging = false;
      });
    } else {
      // Single finger - drag
      setState(() {
        _isDragging = true;
        _isScaling = false;
      });
    }
  }

  /// Handle scale gesture update - handles both pan and pinch
  void _handleScaleUpdate(BuildContext context, ScaleUpdateDetails details) {
    final provider = context.read<PosterProvider>();
    final currentElement = provider.getElementById(widget.element.id);
    if (currentElement == null) return;

    if (details.pointerCount >= 2 || _isScaling) {
      // Pinch gesture - resize with aspect ratio maintained
      if (!_isScaling) {
        setState(() {
          _isScaling = true;
          _isDragging = false;
          _initialWidth = currentElement.width;
          _initialHeight = currentElement.height;
        });
      }

      final scale = details.scale;
      var newWidth = _initialWidth * scale;
      var newHeight = _initialHeight * scale;

      // Maintain aspect ratio
      final aspectRatio = _initialWidth / _initialHeight;
      if (newWidth / newHeight > aspectRatio) {
        newWidth = newHeight * aspectRatio;
      } else {
        newHeight = newWidth / aspectRatio;
      }

      // Enforce minimum size
      newWidth = newWidth.clamp(kMinElementSize, double.infinity);
      newHeight = newHeight.clamp(kMinElementSize, double.infinity);

      provider.updateElementSize(widget.element.id, newWidth, newHeight);
    } else if (_isDragging) {
      // Single finger - move element
      final delta = details.focalPoint - _lastFocalPoint;
      _lastFocalPoint = details.focalPoint;

      // Transform screen delta to canvas coordinates
      final canvasDeltaX = delta.dx / widget.canvasScale;
      final canvasDeltaY = delta.dy / widget.canvasScale;

      // Calculate new position
      final newX = currentElement.x + canvasDeltaX;
      final newY = currentElement.y + canvasDeltaY;

      // Update position (provider handles clamping)
      provider.updateElementPosition(widget.element.id, newX, newY);
    }
  }

  /// Handle scale gesture end
  void _handleScaleEnd(BuildContext context, ScaleEndDetails details) {
    if (!_isDragging && !_isScaling) return;

    final provider = context.read<PosterProvider>();
    provider.bringToFront(widget.element.id);

    setState(() {
      _isDragging = false;
      _isScaling = false;
    });
  }

  /// Handle resize from handle drag
  void _handleResize(
    BuildContext context,
    HandlePosition position,
    Offset delta,
  ) {
    final provider = context.read<PosterProvider>();
    final currentElement = provider.getElementById(widget.element.id);
    if (currentElement == null) return;

    // Transform screen delta to canvas coordinates
    final canvasDeltaX = delta.dx / widget.canvasScale;
    final canvasDeltaY = delta.dy / widget.canvasScale;

    var newX = currentElement.x;
    var newY = currentElement.y;
    var newWidth = currentElement.width;
    var newHeight = currentElement.height;

    // Calculate new position and size based on handle position
    if (position.affectsX) {
      newX += canvasDeltaX;
      newWidth -= canvasDeltaX;
    }
    if (position.affectsY) {
      newY += canvasDeltaY;
      newHeight -= canvasDeltaY;
    }
    if (!position.affectsX && position.affectsWidth) {
      newWidth += canvasDeltaX;
    }
    if (!position.affectsY && position.affectsHeight) {
      newHeight += canvasDeltaY;
    }

    // For QR code, maintain square aspect ratio
    if (widget.element.type == ElementType.qrCode) {
      if (position.isCorner) {
        // Use the larger delta to determine size change
        final sizeDelta = canvasDeltaX.abs() > canvasDeltaY.abs()
            ? canvasDeltaX
            : canvasDeltaY;

        if (position.affectsX && position.affectsY) {
          // Top-left corner: drag left/up = grow, drag right/down = shrink
          final delta = -sizeDelta;
          newX = currentElement.x - delta;
          newY = currentElement.y - delta;
          newWidth = currentElement.width + delta;
          newHeight = currentElement.height + delta;
        } else if (!position.affectsX && position.affectsY) {
          // Top-right corner: drag right/up = grow, drag left/down = shrink
          final delta = (canvasDeltaX - canvasDeltaY) / 2;
          newY = currentElement.y - delta;
          newWidth = currentElement.width + delta;
          newHeight = currentElement.height + delta;
        } else if (position.affectsX && !position.affectsY) {
          // Bottom-left corner: drag left/down = grow, drag right/up = shrink
          final delta = (-canvasDeltaX + canvasDeltaY) / 2;
          newX = currentElement.x - delta;
          newWidth = currentElement.width + delta;
          newHeight = currentElement.height + delta;
        } else {
          // Bottom-right corner: drag right/down = grow, drag left/up = shrink
          newWidth = currentElement.width + sizeDelta;
          newHeight = currentElement.height + sizeDelta;
        }
      } else {
        // Edge handles - maintain square by syncing width and height
        if (position.affectsX) {
          // Left edge: move X, adjust width, center vertically
          newX = currentElement.x + canvasDeltaX;
          newWidth = currentElement.width - canvasDeltaX;
          newHeight = currentElement.height - canvasDeltaX;
          newY = currentElement.y + canvasDeltaX / 2;
        } else if (position.affectsWidth) {
          // Right edge: adjust width, center vertically
          newWidth = currentElement.width + canvasDeltaX;
          newHeight = currentElement.height + canvasDeltaX;
          newY = currentElement.y - canvasDeltaX / 2;
        } else if (position.affectsY) {
          // Top edge: move Y, adjust height, center horizontally
          newY = currentElement.y + canvasDeltaY;
          newHeight = currentElement.height - canvasDeltaY;
          newWidth = currentElement.width - canvasDeltaY;
          newX = currentElement.x + canvasDeltaY / 2;
        } else if (position.affectsHeight) {
          // Bottom edge: adjust height, center horizontally
          newHeight = currentElement.height + canvasDeltaY;
          newWidth = currentElement.width + canvasDeltaY;
          newX = currentElement.x - canvasDeltaY / 2;
        }
      }
    }

    // Enforce minimum size
    if (widget.element.type == ElementType.qrCode) {
      // QR code must stay square - use the larger of the two for minimum
      if (newWidth < kMinElementSize || newHeight < kMinElementSize) {
        // Don't resize below minimum, keep current size
        newWidth = currentElement.width;
        newHeight = currentElement.height;
        newX = currentElement.x;
        newY = currentElement.y;
      }
    } else {
      if (newWidth < kMinElementSize) {
        if (position.affectsX) {
          newX = currentElement.x + currentElement.width - kMinElementSize;
        }
        newWidth = kMinElementSize;
      }
      if (newHeight < kMinElementSize) {
        if (position.affectsY) {
          newY = currentElement.y + currentElement.height - kMinElementSize;
        }
        newHeight = kMinElementSize;
      }
    }

    // Update position and size
    provider.updateElementPosition(widget.element.id, newX, newY);
    provider.updateElementSize(widget.element.id, newWidth, newHeight);
  }

  /// Handle resize end from handle drag
  void _handleResizeEnd(BuildContext context) {
    final provider = context.read<PosterProvider>();
    provider.bringToFront(widget.element.id);
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.element.type) {
      case ElementType.qrCode:
        return _buildQrCode(context);
      case ElementType.title:
        return _buildTitle(context);
      case ElementType.message:
        return _buildMessage(context);
      case ElementType.ssidPassword:
        return _buildSsidPassword(context);
      case ElementType.signature:
        return _buildSignature(context);
      case ElementType.wifiIcon:
        return _buildWifiIcon(context);
    }
  }

  Widget _buildQrCode(BuildContext context) {
    final provider = context.read<PosterProvider>();

    return QrWidget(
      data: provider.wifiConfig.toQrString(),
      size: widget.element.width * widget.canvasScale,
      backgroundColor: widget.element.backgroundColor ?? Colors.white,
      foregroundColor: widget.element.textColor ?? Colors.black,
      iconId: provider.selectedIconPath,
      customIconData: provider.customIconData,
    );
  }

  Widget _buildTitle(BuildContext context) {
    final provider = context.read<PosterProvider>();
    final locale = context.read<LocaleProvider>();
    final lang = locale.locale.languageCode;

    final displayText =
        widget.element.content ??
        (provider.posterTitle.isNotEmpty
            ? provider.posterTitle
            : AppTranslations.get('free_wifi', lang));

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        displayText,
        style: FontPicker.getStyleById(
          widget.element.fontFamily ?? provider.selectedFont,
          fontSize: (widget.element.fontSize ?? 24) * widget.canvasScale,
          fontWeight: FontWeight.bold,
          color: widget.element.textColor ?? Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Center(
      child: Text(
        widget.element.content ?? '',
        style: FontPicker.getStyleById(
          widget.element.fontFamily ?? 'noto',
          fontSize: (widget.element.fontSize ?? 16) * widget.canvasScale,
          fontWeight: FontWeight.w500,
          color: widget.element.textColor ?? Colors.black,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSsidPassword(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.element.content ?? '',
          style: FontPicker.getStyleById(
            widget.element.fontFamily ?? 'noto',
            fontSize: (widget.element.fontSize ?? 14) * widget.canvasScale,
            fontWeight: FontWeight.w500,
            color: widget.element.textColor ?? Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSignature(BuildContext context) {
    return Center(
      child: Text(
        widget.element.content ?? '',
        style: FontPicker.getStyleById(
          widget.element.fontFamily ?? 'noto',
          fontSize: (widget.element.fontSize ?? 16) * widget.canvasScale,
          fontWeight: FontWeight.w600,
          color: widget.element.textColor ?? Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWifiIcon(BuildContext context) {
    return Center(
      child: Icon(
        Icons.wifi,
        size: widget.element.width * widget.canvasScale * 0.8,
        color: widget.element.textColor ?? Colors.black,
      ),
    );
  }
}
