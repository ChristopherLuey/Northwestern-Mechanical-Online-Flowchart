// lib/src/course_box.dart

import 'package:flutter/material.dart';

class CourseBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String term;

  // Define style and padding variables
  static const double padding = 8.0;
  static const double spacing = 4.0;
  static const TextStyle titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const TextStyle subtitleStyle = TextStyle(fontSize: 14);
  static const TextStyle termStyle = TextStyle(fontSize: 12, color: Colors.red);

  const CourseBox({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.term,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: titleStyle,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing),
          Text(
            subtitle,
            style: subtitleStyle,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing),
          Text(
            term,
            style: termStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}