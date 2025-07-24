import 'package:flutter/material.dart';

/// 그리드 아이템 모델
class GridItem {
  final String id;
  final String text;
  final String url;
  final String description;

  GridItem({
    required this.id,
    required this.text,
    required this.url,
    required this.description,
  });

  factory GridItem.fromJson(Map<String, dynamic> json) {
    return GridItem(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'url': url,
      'description': description,
    };
  }
} 