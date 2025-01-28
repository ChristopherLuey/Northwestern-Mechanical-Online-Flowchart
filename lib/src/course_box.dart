// lib/src/course_box.dart

import 'package:flutter/material.dart';

class CourseBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String term;
  final int year; // Year used internally
  final TextAlign textAlign; // New parameter for text alignment
  final VoidCallback? onTap; // New parameter for tap callback
  final bool isCurriculumPlanner; // New parameter to determine layout style
  final String term_taking; // New parameter for term_taking

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
    required this.year, // Initialize year
    this.textAlign = TextAlign.center, // Default alignment
    this.onTap, // Default onTap is null
    this.isCurriculumPlanner = false, // Default to false for FlowchartViewer
    required this.term_taking, // Initialize term_taking
  }) : super(key: key);

  BoxDecoration _getColorForYear(int year) {
    switch (year) {
      case 1:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        );
      case 2:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        );
      case 3:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        );
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget courseContent = Container(
      decoration: _getColorForYear(year),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: textAlign == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  if (isCurriculumPlanner)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: textAlign,
                        ),
                        Text(
                          term,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: textAlign,
                        ),
                      ],
                    )
                  else
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: textAlign,
                    ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: textAlign,
                  ),
                  if (!isCurriculumPlanner)
                    SizedBox(height: 4),
                  if (!isCurriculumPlanner)
                    Text(
                      term,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: textAlign,
                    ),
                ],
              ),
            ),
            if (!isCurriculumPlanner && term_taking != 'Not Set')
              Positioned(
                right: 4,
                top: 4,
                child: Icon(
                  Icons.check_circle,
                  color: const Color.fromARGB(255, 125, 230, 130),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: courseContent,
      );
    } else {
      return courseContent;
    }
  }
}