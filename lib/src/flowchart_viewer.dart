import 'package:flutter/material.dart';
import 'course_box.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class FlowchartViewer extends StatefulWidget {
  const FlowchartViewer({Key? key}) : super(key: key);

  @override
  _FlowchartViewerState createState() => _FlowchartViewerState();
}

class _FlowchartViewerState extends State<FlowchartViewer> {
  final Size courseBoxSize = Size(200, 100);

  // Define positions for each course box
  final Map<String, Offset> positions = {
    'GEN_ENG 205-1': Offset(50, 100),
    'MATH 220-1': Offset(300, 100),
    'MATH 220-2': Offset(550, 100),
    'PHYSICS 135-2/136-2': Offset(800, 100),
    'GEN_ENG 205-2': Offset(50, 250),
    'COMM_ST 102': Offset(300, 250),
    'DSGN 106-1': Offset(550, 250),
    'CHEM 131/141': Offset(50, 400),
    'GEN_ENG 205-3': Offset(300, 400),
    'CIV_ENV 216': Offset(550, 400),
    'MECH_ENG 233': Offset(800, 400),
    'MECH_ENG 222': Offset(1050, 400),
    'MECH_ENG 224': Offset(1300, 400),
    'MECH_ENG 240': Offset(50, 550),
    'MECH_ENG 315': Offset(300, 550),
    'MECH_ENG 340-1': Offset(550, 550),
    'MECH_ENG 390': Offset(800, 550),
    'MECH_ENG 241': Offset(1050, 550),
    'MECH_ENG 377': Offset(1300, 550),
    'MECH_ENG 314': Offset(1550, 550),
    'MECH_ENG 398-1': Offset(50, 700),
    'MECH_ENG 398-2': Offset(300, 700),
  };

  // Define prerequisites
  final Map<String, List<String>> prerequisites = {
    'MATH 220-2': ['MATH 220-1'],
    'PHYSICS 135-2/136-2': ['MATH 220-1'],
    'GEN_ENG 205-2': ['GEN_ENG 205-1'],
    'GEN_ENG 205-3': ['GEN_ENG 205-2'],
    'MECH_ENG 233': ['GEN_ENG 205-3'],
    'MECH_ENG 222': ['GEN_ENG 205-3'],
    'MECH_ENG 224': ['GEN_ENG 205-3'],
    'MECH_ENG 240': ['CIV_ENV 216'],
    'MECH_ENG 315': ['MECH_ENG 240'],
    'MECH_ENG 340-1': ['MECH_ENG 240'],
    'MECH_ENG 390': ['MECH_ENG 233'],
    'MECH_ENG 241': ['MECH_ENG 222'],
    'MECH_ENG 377': ['MECH_ENG 241'],
    'MECH_ENG 314': ['MECH_ENG 241'],
    'MECH_ENG 398-1': ['MECH_ENG 315'],
    'MECH_ENG 398-2': ['MECH_ENG 398-1'],
  };

  Offset panOffset = Offset.zero;
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              setState(() {
                final zoomFactor = 0.05; // Less sensitive zoom
                final newScale = scale + (event.scrollDelta.dy > 0 ? -zoomFactor : zoomFactor);
                final mousePosition = event.localPosition;

                // Calculate the new panOffset to zoom towards the mouse position
                final scaleChange = newScale / scale;
                panOffset = (panOffset - mousePosition) * scaleChange + mousePosition;

                scale = newScale.clamp(0.5, 3.0); // Limit zoom levels
              });
            }
          },
          child: GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                scale *= details.scale;
                panOffset += details.focalPointDelta;
              });
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: 2000, // Set a large enough width
                  height: 1000, // Set a large enough height
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(panOffset.dx, panOffset.dy)
                      ..scale(scale),
                    child: Stack(
                      children: <Widget>[
                        CustomPaint(
                          size: Size.infinite,
                          painter: FlowchartPainter(positions, courseBoxSize, prerequisites),
                        ),
                        ...positions.entries.map((entry) {
                          return Positioned(
                            top: entry.value.dy,
                            left: entry.value.dx,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  positions[entry.key] = entry.value + details.delta * 2.0;
                                });
                              },
                              child: SizedBox(
                                width: courseBoxSize.width,
                                height: courseBoxSize.height,
                                child: CourseBox(
                                  title: entry.key,
                                  subtitle: _getSubtitle(entry.key),
                                  term: _getTerm(entry.key),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSubtitle(String course) {
    switch (course) {
      case 'GEN_ENG 205-1':
        return 'Eng Analysis I';
      case 'MATH 220-1':
        return 'Single Var Diff Calc';
      case 'MATH 220-2':
        return 'Single Var Int Calc';
      case 'PHYSICS 135-2/136-2':
        return 'E&M';
      case 'GEN_ENG 205-2':
        return 'Eng Analysis II';
      case 'COMM_ST 102':
        return 'Or PERF_ST 103';
      case 'DSGN 106-1':
        return 'Dsgn Thinking and Communication I';
      case 'CHEM 131/141':
        return 'Or CHEM 151/161';
      case 'GEN_ENG 205-3':
        return 'Eng Analysis III';
      case 'CIV_ENV 216':
        return 'Mech. of Materials';
      case 'MECH_ENG 233':
        return 'Electronics Design';
      case 'MECH_ENG 222':
        return 'Thermo I';
      case 'MECH_ENG 224':
        return 'Sci Embed Prog Python';
      case 'MECH_ENG 240':
        return 'Mech Design & Manufacturing';
      case 'MECH_ENG 315':
        return 'Thry of Machines: Dsgn of Elements';
      case 'MECH_ENG 340-1':
        return 'Manuf Processes';
      case 'MECH_ENG 390':
        return 'Intro to Dynamic Systems';
      case 'MECH_ENG 241':
        return 'Fluid Mech';
      case 'MECH_ENG 377':
        return 'Heat Transfer';
      case 'MECH_ENG 314':
        return 'Dynamics';
      case 'MECH_ENG 398-1':
        return 'Engineering Dsgn';
      case 'MECH_ENG 398-2':
        return 'Engineering Dsgn';
      default:
        return '';
    }
  }

  String _getTerm(String course) {
    switch (course) {
      case 'GEN_ENG 205-1':
        return '[FW]';
      case 'MATH 220-1':
        return '[FW]';
      case 'MATH 220-2':
        return '[FWS]';
      case 'PHYSICS 135-2/136-2':
        return '[FW]';
      case 'GEN_ENG 205-2':
        return '[WS]';
      case 'COMM_ST 102':
        return '[FW]';
      case 'DSGN 106-1':
        return '[FW]';
      case 'CHEM 131/141':
        return '[FW]';
      case 'GEN_ENG 205-3':
        return '[FWS]';
      case 'CIV_ENV 216':
        return '[FWS]';
      case 'MECH_ENG 233':
        return '[F]';
      case 'MECH_ENG 222':
        return '[W]';
      case 'MECH_ENG 224':
        return '[WS]';
      case 'MECH_ENG 240':
        return '[S]';
      case 'MECH_ENG 315':
        return '[FS]';
      case 'MECH_ENG 340-1':
        return '[F]';
      case 'MECH_ENG 390':
        return '[F]';
      case 'MECH_ENG 241':
        return '[FS]';
      case 'MECH_ENG 377':
        return '[WS]';
      case 'MECH_ENG 314':
        return '[FS]';
      case 'MECH_ENG 398-1':
        return '[FW]';
      case 'MECH_ENG 398-2':
        return '[WS]';
      default:
        return '';
    }
  }
}

class FlowchartPainter extends CustomPainter {
  final Map<String, Offset> positions;
  final Size courseBoxSize;
  final Map<String, List<String>> prerequisites;

  FlowchartPainter(this.positions, this.courseBoxSize, this.prerequisites);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    for (var entry in prerequisites.entries) {
      final course = entry.key;
      final prereqs = entry.value;

      for (var prereq in prereqs) {
        final startCenter = positions[prereq]! + Offset(courseBoxSize.width / 2, courseBoxSize.height / 2);
        final endCenter = positions[course]! + Offset(courseBoxSize.width / 2, courseBoxSize.height / 2);

        final direction = (endCenter - startCenter);
        final normalizedDirection = direction / direction.distance;
        final start = _calculateEdgeIntersection(startCenter, normalizedDirection, courseBoxSize.width, courseBoxSize.height);
        final end = _calculateEdgeIntersection(endCenter, -normalizedDirection, courseBoxSize.width, courseBoxSize.height);

        canvas.drawLine(start, end, paint);

        // Draw arrowhead
        final arrowPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

        const arrowSize = 15.0;
        final angle = atan2(end.dy - start.dy, end.dx - start.dx);
        final path = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - arrowSize * cos(angle - pi / 6), end.dy - arrowSize * sin(angle - pi / 6))
          ..lineTo(end.dx - arrowSize * cos(angle + pi / 6), end.dy - arrowSize * sin(angle + pi / 6))
          ..close();

        canvas.drawPath(path, arrowPaint);
      }
    }
  }

  Offset _calculateEdgeIntersection(Offset center, Offset direction, double width, double height) {
    final dx = direction.dx;
    final dy = direction.dy;
    double scale;

    if (dx.abs() * height > dy.abs() * width) {
      scale = (width / 2) / dx.abs();
    } else {
      scale = (height / 2) / dy.abs();
    }

    return center + direction * scale;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}