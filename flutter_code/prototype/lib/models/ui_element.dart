import 'dart:convert';
import 'package:flutter/material.dart';

/// UI 요소의 경계를 나타내는 클래스
class UIBounds {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final double width;
  final double height;

  UIBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.width,
    required this.height,
  });

  factory UIBounds.fromJson(Map<String, dynamic> json) {
    return UIBounds(
      left: json['left']?.toDouble() ?? 0.0,
      top: json['top']?.toDouble() ?? 0.0,
      right: json['right']?.toDouble() ?? 0.0,
      bottom: json['bottom']?.toDouble() ?? 0.0,
      width: json['width']?.toDouble() ?? 0.0,
      height: json['height']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
      'width': width,
      'height': height,
    };
  }
}

/// UI 요소의 종류를 나타내는 열거형
enum UIElementType {
  button,
  text,
  image,
  link,
  input,
  checkbox,
  radio,
  switchElement,
  slider,
  progress,
  tab,
  menu,
  dialog,
  unknown,
}

/// UI 요소를 나타내는 클래스
class UIElement {
  final String id;
  final String text;
  final String? contentDescription;
  final UIElementType type;
  final UIBounds bounds;
  final bool isClickable;
  final bool isEnabled;
  final bool isVisible;
  final Map<String, dynamic>? additionalProperties;

  UIElement({
    required this.id,
    required this.text,
    this.contentDescription,
    required this.type,
    required this.bounds,
    required this.isClickable,
    required this.isEnabled,
    required this.isVisible,
    this.additionalProperties,
  });

  factory UIElement.fromJson(Map<String, dynamic> json) {
    return UIElement(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      contentDescription: json['contentDescription'],
      type: _parseElementType(json['type']),
      bounds: UIBounds.fromJson(json['bounds'] ?? {}),
      isClickable: json['isClickable'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      isVisible: json['isVisible'] ?? true,
      additionalProperties: json['additionalProperties'],
    );
  }

  static UIElementType _parseElementType(String? type) {
    switch (type?.toLowerCase()) {
      case 'button':
        return UIElementType.button;
      case 'text':
        return UIElementType.text;
      case 'image':
        return UIElementType.image;
      case 'link':
        return UIElementType.link;
      case 'input':
        return UIElementType.input;
      case 'checkbox':
        return UIElementType.checkbox;
      case 'radio':
        return UIElementType.radio;
      case 'switch':
        return UIElementType.switchElement;
      case 'slider':
        return UIElementType.slider;
      case 'progress':
        return UIElementType.progress;
      case 'tab':
        return UIElementType.tab;
      case 'menu':
        return UIElementType.menu;
      case 'dialog':
        return UIElementType.dialog;
      default:
        return UIElementType.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'contentDescription': contentDescription,
      'type': type.toString().split('.').last,
      'bounds': bounds.toJson(),
      'isClickable': isClickable,
      'isEnabled': isEnabled,
      'isVisible': isVisible,
      'additionalProperties': additionalProperties,
    };
  }

  /// 요소의 중심점 계산
  Offset get center {
    return Offset(
      bounds.left + (bounds.width / 2),
      bounds.top + (bounds.height / 2),
    );
  }

  /// 요소가 화면에 보이는지 확인
  bool get isOnScreen {
    return bounds.left >= 0 && 
           bounds.top >= 0 && 
           bounds.right > 0 && 
           bounds.bottom > 0;
  }

  /// 요소의 크기가 최소 크기 이상인지 확인
  bool get hasMinimumSize {
    return bounds.width >= 10 && bounds.height >= 10;
  }

  /// 텍스트 매칭 점수 계산 (0.0 ~ 1.0)
  double calculateTextMatchScore(String query) {
    if (text.isEmpty) return 0.0;
    
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    
    // 정확한 일치
    if (textLower == queryLower) return 1.0;
    
    // 포함 관계
    if (textLower.contains(queryLower)) return 0.8;
    if (queryLower.contains(textLower)) return 0.6;
    
    // 단어 단위 매칭
    final queryWords = queryLower.split(' ');
    final textWords = textLower.split(' ');
    
    int matchCount = 0;
    for (final queryWord in queryWords) {
      for (final textWord in textWords) {
        if (textWord.contains(queryWord) || queryWord.contains(textWord)) {
          matchCount++;
          break;
        }
      }
    }
    
    if (matchCount > 0) {
      return (matchCount / queryWords.length) * 0.7;
    }
    
    return 0.0;
  }

  @override
  String toString() {
    return 'UIElement(id: $id, text: "$text", type: $type, bounds: $bounds)';
  }
} 