import 'package:flutter/material.dart';
import '../../models/ui_element.dart';

/// 접근성 서비스로 감지된 UI 요소를 시각적으로 하이라이트하는 오버레이
class AccessibilityOverlay extends StatefulWidget {
  final UIElement? highlightedElement;
  final Duration highlightDuration;
  final Color highlightColor;
  final double opacity;

  const AccessibilityOverlay({
    super.key,
    this.highlightedElement,
    this.highlightDuration = const Duration(seconds: 3),
    this.highlightColor = Colors.red,
    this.opacity = 0.3,
  });

  @override
  State<AccessibilityOverlay> createState() => _AccessibilityOverlayState();
}

class _AccessibilityOverlayState extends State<AccessibilityOverlay>
    with TickerProviderStateMixin {
  UIElement? _currentHighlightedElement;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.highlightDuration,
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(AccessibilityOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.highlightedElement != _currentHighlightedElement) {
      _currentHighlightedElement = widget.highlightedElement;
      if (_currentHighlightedElement != null) {
        _startHighlightAnimation();
      } else {
        _stopHighlightAnimation();
      }
    }
  }

  void _startHighlightAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  void _stopHighlightAnimation() {
    _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentHighlightedElement == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: _currentHighlightedElement!.bounds.left,
          top: _currentHighlightedElement!.bounds.top,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: _currentHighlightedElement!.bounds.width,
              height: _currentHighlightedElement!.bounds.height,
              decoration: BoxDecoration(
                color: widget.highlightColor.withOpacity(_opacityAnimation.value),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.highlightColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.highlightColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.touch_app,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 여러 UI 요소를 동시에 하이라이트하는 오버레이
class MultiElementOverlay extends StatelessWidget {
  final List<UIElement> elements;
  final Color highlightColor;
  final double opacity;

  const MultiElementOverlay({
    super.key,
    required this.elements,
    this.highlightColor = Colors.blue,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: elements.map((element) {
        return Positioned(
          left: element.bounds.left,
          top: element.bounds.top,
          child: Container(
            width: element.bounds.width,
            height: element.bounds.height,
            decoration: BoxDecoration(
              color: highlightColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: highlightColor,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// UI 요소 정보를 표시하는 툴팁
class ElementInfoTooltip extends StatelessWidget {
  final UIElement element;
  final Offset position;

  const ElementInfoTooltip({
    super.key,
    required this.element,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              element.text.isNotEmpty ? element.text : '빈 요소',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '타입: ${element.type.toString().split('.').last}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            if (element.isClickable)
              const Text(
                '클릭 가능',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 