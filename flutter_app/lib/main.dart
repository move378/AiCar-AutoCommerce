import 'package:aicar/core/theme/app_theme.dart';
import 'package:aicar/presentation/pages/_dev/widget_catalog_page.dart';
import 'package:flutter/material.dart';

// 임시 Widget Catalog 모드 — 개발 확인 후 원복
void main() {
  runApp(
    MaterialApp(
      title: 'AiCar Widget Catalog',
      theme: AppTheme.light,
      home: const WidgetCatalogPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
