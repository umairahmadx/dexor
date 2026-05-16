import 'package:flutter/material.dart';

class ToolEntry {
  const ToolEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.tags,
    required this.route,
    this.isNew = false,
    this.accentOverride,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final List<String> tags;
  final String route;
  final bool isNew;
  final Color? accentOverride;
}

