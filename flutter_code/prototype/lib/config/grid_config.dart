import 'package:flutter/material.dart';
import '../models/grid_item.dart';

class GridConfig {
  static List<GridItem> get defaultItems => [
    GridItem(
      id: '1',
      text: 'Google',
      url: 'https://google.com',
      description: '검색',
    ),
    GridItem(
      id: '2',
      text: 'YouTube',
      url: 'https://youtube.com',
      description: '동영상',
    ),
    GridItem(
      id: '3',
      text: 'Naver',
      url: 'https://naver.com',
      description: '포털',
    ),
    GridItem(
      id: '4',
      text: 'GitHub',
      url: 'https://github.com',
      description: '개발',
    ),
    GridItem(
      id: '5',
      text: 'Facebook',
      url: 'https://facebook.com',
      description: '소셜',
    ),
    GridItem(
      id: '6',
      text: 'Twitter',
      url: 'https://twitter.com',
      description: '소셜',
    ),
    GridItem(
      id: '7',
      text: 'Instagram',
      url: 'https://instagram.com',
      description: '소셜',
    ),
    GridItem(
      id: '8',
      text: 'LinkedIn',
      url: 'https://linkedin.com',
      description: '비즈니스',
    ),
    GridItem(
      id: '9',
      text: 'Reddit',
      url: 'https://reddit.com',
      description: '커뮤니티',
    ),
    GridItem(
      id: '10',
      text: 'Wikipedia',
      url: 'https://wikipedia.org',
      description: '지식',
    ),
    GridItem(
      id: '11',
      text: 'Stack Overflow',
      url: 'https://stackoverflow.com',
      description: '개발',
    ),
    GridItem(
      id: '12',
      text: 'Daum',
      url: 'https://daum.net',
      description: '포털',
    ),
  ];
} 