import 'package:flutter/material.dart';
import 'course_box.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:developer' as developer;

final Size globalCanvasSize = Size(8000, 5000); // Global canvas size

class FlowchartViewer extends StatefulWidget {
  const FlowchartViewer({Key? key}) : super(key: key);

  @override
  FlowchartViewerState createState() => FlowchartViewerState();
}

class FlowchartViewerState extends State<FlowchartViewer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Size courseBoxSize = Size(200, 100);

  // Original positions for each course box

  final Map<String, Offset> _originalPositions = {
    'GEN_ENG 205-1': Offset(368.2, 181.8),
    'MATH 220-1': Offset(67.0, 0.0),
    'PHYSICS 135-2/136-2': Offset(935.4, 0.0),
    'MATH 220-2': Offset(68.6, 281.2),
    'GEN_ENG 205-2': Offset(649.1, 177.1),
    'PHYSICS 135-3/136-3': Offset(1489.3, 0.0),
    'GEN_ENG 205-3': Offset(651.6, 416.9),
    'MECH_ENG 222': Offset(962.4, 404.7),
    'CIV_ENV 216': Offset(1180.1, 304.9),
    'MECH_ENG 224': Offset(1167.7, 122.2),
    'GEN_ENG 205-4': Offset(371.7, 415.7),
    'MECH_ENG 314': Offset(761.0, 609.6),
    'MECH_ENG 241': Offset(386.0, 690.8),
    'MECH_ENG 377': Offset(757.7, 805.8),
    'MECH_ENG 390': Offset(1138.3, 587.7),
    'MATH 228-1': Offset(69.6, 491.8),
    'MAT_SCI 201': Offset(1831.9, 278.3),
    'MECH_ENG 240': Offset(1648.3, 118.1),
    'MECH_ENG 315': Offset(1671.3, 480.5),
    'MATH 228-2': Offset(71.5, 691.1),
    'CHEM 131/141': Offset(2027.0, 456.7),
    'MECH_ENG 340-1': Offset(1400.8, 470.8),
    'MECH_ENG 233': Offset(1041.8, 832.9),
    'COMM_ST 102': Offset(1296.5, 828.1),
    'DSGN 106-1': Offset(1842.4, 634.0),
    'DSGN 106-2': Offset(1578.2, 811.1),
    'MECH_ENG 398-1': Offset(210.4, 926.8),
    'MECH_ENG 398-2': Offset(559.6, 922.7),
  };

  Map<String, Offset> positions = {};

  // Define prerequisites
  final Map<String, List<String>> prerequisites = {
    'MATH 220-2': ['MATH 220-1'],
    'MATH 228-1': ['MATH 220-2'],
    'MATH 228-2': ['MATH 228-1'],
    'DSGN 106-2': ['DSGN 106-1'],
    'PHYSICS 135-2/136-2': ['MATH 220-1', 'GEN_ENG 205-3'],
    'PHYSICS 135-3/136-3': ['PHYSICS 135-2/136-2'],
    'GEN_ENG 205-2': ['GEN_ENG 205-1', 'MATH 220-1'],
    'GEN_ENG 205-3': ['GEN_ENG 205-2'],
    'GEN_ENG 205-4': ['GEN_ENG 205-3', 'MATH 220-2'],
    'MAT_SCI 201': ['CHEM 131/141'],
    'CIV_ENV 216': ['GEN_ENG 205-2'],
    'MECH_ENG 240': ['CIV_ENV 216', 'MAT_SCI 201'],
    'MECH_ENG 233': [],
    'MECH_ENG 222': ['GEN_ENG 205-3'],
    'MECH_ENG 224': ['GEN_ENG 205-2'],
    'MECH_ENG 315': ['MECH_ENG 240'],
    'MECH_ENG 340-1': ['MECH_ENG 240'],
    'MECH_ENG 241': ['MATH 228-2', 'GEN_ENG 205-4'],
    'MECH_ENG 377': ['MECH_ENG 241'],
    'MECH_ENG 390': ['CIV_ENV 216', 'MECH_ENG 377'],
    'MECH_ENG 314': ['GEN_ENG 205-4'],
    'MECH_ENG 398-1': [],
    'MECH_ENG 398-2': ['MECH_ENG 398-1'],
  };

  Offset panOffset = Offset.zero;
  double scale = 1.0;

  String? selectedCourse;

  @override
  void initState() {
    super.initState();
    _initializeFlowchart();
  }

  void _initializeFlowchart() {
    positions = Map.from(_originalPositions);
    positions.forEach((key, value) {
      developer.log('Initial position of $key: $value', name: 'FlowchartViewer');
    });
  }

  void resetFlowchart() {
    setState(() {
      _initializeFlowchart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: selectedCourse != null ? _buildCoursePanel() : null,
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() {
            selectedCourse = null; // Reset the selected course when drawer is closed
            developer.log('Drawer closed, selected course reset to null', name: 'FlowchartViewer');
          });
        }
      },
      body: Stack(
        children: [
          Center(
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  setState(() {
                    final zoomFactor = 0.05;
                    final newScale = scale + (event.scrollDelta.dy > 0 ? -zoomFactor : zoomFactor);
                    final mousePosition = event.localPosition;

                    final scaleChange = newScale / scale;
                    panOffset = (panOffset - mousePosition) * scaleChange + mousePosition;

                    scale = newScale.clamp(0.5, 3.0);
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
                      width: globalCanvasSize.width,
                      height: globalCanvasSize.height,
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
                              final isSelected = entry.key == selectedCourse;
                              developer.log('Rendering ${entry.key} at position ${entry.value}', name: 'FlowchartViewer');
                              return Positioned(
                                top: entry.value.dy,
                                left: entry.value.dx,
                                child: GestureDetector(
                                  onTap: () {
                                    _onBubbleTap(entry.key);
                                  },
                                  onPanUpdate: (details) {
                                    setState(() {
                                      final newPosition = entry.value + details.delta * 2.0;
                                      positions[entry.key] = _clampPosition(newPosition);
                                      _resolveAllCollisions();
                                    });
                                  },
                                  child: Container(
                                    width: courseBoxSize.width,
                                    height: courseBoxSize.height,
                                    decoration: BoxDecoration(
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 10,
                                                offset: Offset(0, 0), // changes position of shadow
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: CourseBox(
                                      title: entry.key,
                                      subtitle: _getSubtitle(entry.key),
                                      term: _getTerm(entry.key),
                                      year: _getYear(entry.key),
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
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  resetFlowchart(); // Reset positions when button is pressed
                });
              },
              child: Icon(Icons.refresh),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                // Define the action for the plus button here
              },
              child: Icon(Icons.add),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                logCurrentPositions(); // Log positions when button is pressed
              },
              child: Icon(Icons.save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePanel() {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text(selectedCourse ?? ''),
            automaticallyImplyLeading: false,
          ),
          // Add more details about the course here
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Details about $selectedCourse'),
          ),
        ],
      ),
    );
  }

  void _resolveAllCollisions() {
    positions.forEach((key, currentPos) {
      positions.forEach((otherKey, otherPos) {
        if (key != otherKey) {
          final dx = currentPos.dx - otherPos.dx;
          final dy = currentPos.dy - otherPos.dy;
          final overlapX = courseBoxSize.width - dx.abs();
          final overlapY = courseBoxSize.height - dy.abs();

          if (overlapX > 0 && overlapY > 0) {
            if (overlapX < overlapY) {
              final directionX = dx > 0 ? 1 : -1;
              final newCurrentPos = currentPos.translate(directionX * overlapX / 2, 0);
              final newOtherPos = otherPos.translate(-directionX * overlapX / 2, 0);

              positions[key] = _clampPosition(newCurrentPos);
              positions[otherKey] = _clampPosition(newOtherPos);
            } else {
              final directionY = dy > 0 ? 1 : -1;
              final newCurrentPos = currentPos.translate(0, directionY * overlapY / 2);
              final newOtherPos = otherPos.translate(0, -directionY * overlapY / 2);

              positions[key] = _clampPosition(newCurrentPos);
              positions[otherKey] = _clampPosition(newOtherPos);
            }
          }
        }
      });
    });

    positions.forEach((key, value) {
      developer.log('Resolved position of $key: $value', name: 'FlowchartViewer');
    });
  }

  Offset _clampPosition(Offset position) {
    final maxX = globalCanvasSize.width - courseBoxSize.width;
    final maxY = globalCanvasSize.height - courseBoxSize.height;
    return Offset(
      position.dx.clamp(0.0, maxX),
      position.dy.clamp(0.0, maxY),
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
      case 'MATH 228-1':
        return 'Multivar Diff Calc';
      case 'MATH 228-2':
        return 'Multivar Int Calc';
      case 'PHYSICS 135-2/136-2':
        return 'E&M';
      case 'PHYSICS 135-3/136-3':
        return 'Waves and Motion';
      case 'GEN_ENG 205-2':
        return 'Eng Analysis II';
      case 'COMM_ST 102':
        return 'Or PERF_ST 103 or PERF_ST 203';
      case 'DSGN 106-1':
        return 'Dsgn Thinking and Communication I';
      case 'DSGN 106-2':
        return 'Dsgn Thinking and Communication II';
      case 'CHEM 131/141':
        return 'Or CHEM 151/161 or CHEM 171/181';
      case 'MAT_SCI 201':
        return 'Materials Science';
      case 'GEN_ENG 205-3':
        return 'Eng Analysis III';
      case 'GEN_ENG 205-4':
        return 'Eng Analysis IV';
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
        return '[FW ]';
      case 'MATH 220-1':
        return '[FW ]';
      case 'MATH 220-2':
        return '[FWS]';
      case 'MATH 228-1':
        return '[FWS]';
      case 'MATH 228-2':
        return '[FWS]';
      case 'PHYSICS 135-2/136-2':
        return '[FW ]';
      case 'PHYSICS 135-3/136-3':
        return '[ WS]';
      case 'GEN_ENG 205-2':
        return '[ WS]';
      case 'COMM_ST 102':
        return '[FWS]';
      case 'DSGN 106-1':
        return '[FW ]';
      case 'DSGN 106-2':
        return '[  S]';
      case 'CHEM 131/141':
        return '[FWS]';
      case 'GEN_ENG 205-3':
        return '[F S]';
      case 'GEN_ENG 205-4':
        return '[FW ]';
      case 'MAT_SCI 201':
        return '[FWS]';
      case 'CIV_ENV 216':
        return '[FWS]';
      case 'MECH_ENG 233':
        return '[F  ]';
      case 'MECH_ENG 222':
        return '[ W ]';
      case 'MECH_ENG 224':
        return '[ WS]';
      case 'MECH_ENG 240':
        return '[  S]';
      case 'MECH_ENG 315':
        return '[F S]';
      case 'MECH_ENG 340-1':
        return '[F  ]';
      case 'MECH_ENG 390':
        return '[F  ]';
      case 'MECH_ENG 241':
        return '[F S]';
      case 'MECH_ENG 377':
        return '[ WS]';
      case 'MECH_ENG 314':
        return '[F S]';
      case 'MECH_ENG 398-1':
        return '[FW ]';
      case 'MECH_ENG 398-2':
        return '[ WS]';
      default:
        return '';
    }
  }

  int _getYear(String course) {
    switch (course) {
      case 'GEN_ENG 205-1':
        return 1;
      case 'MATH 220-1':
        return 1;
      case 'MATH 220-2':
        return 1;
      case 'MATH 228-1':
        return 1;
      case 'MATH 228-2':
        return 1;
      case 'PHYSICS 135-2/136-2':
        return 2;
      case 'PHYSICS 135-3/136-3':
        return 2;
      case 'GEN_ENG 205-2':
        return 1;
      case 'COMM_ST 102':
        return 3;
      case 'DSGN 106-1':
        return 1;
      case 'DSGN 106-2':
        return 1;
      case 'CHEM 131/141':
        return 1;
      case 'GEN_ENG 205-3':
        return 1;
      case 'GEN_ENG 205-4':
        return 2;
      case 'MAT_SCI 201':
        return 2;
      case 'CIV_ENV 216':
        return 2;
      case 'MECH_ENG 233':
        return 2;
      case 'MECH_ENG 222':
        return 2;
      case 'MECH_ENG 224':
        return 2;
      case 'MECH_ENG 240':
        return 2;
      case 'MECH_ENG 315':
        return 3;
      case 'MECH_ENG 340-1':
        return 3;
      case 'MECH_ENG 390':
        return 3;
      case 'MECH_ENG 241':
        return 2;
      case 'MECH_ENG 377':
        return 3;
      case 'MECH_ENG 314':
        return 3;
      case 'MECH_ENG 398-1':
        return 4;
      case 'MECH_ENG 398-2':
        return 4;
      default:
        return 0;
    }
  }

  void _onBubbleTap(String course) {
    setState(() {
      selectedCourse = course; // Set the selected course
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openEndDrawer(); // Open the drawer immediately after state update
    });
  }

  void _log(String message) {
    developer.log(message, name: 'FlowchartViewer');
  }

  void logCurrentPositions() {
    final buffer = StringBuffer();
    buffer.writeln('final Map<String, Offset> _originalPositions = {');
    positions.forEach((key, value) {
      buffer.writeln("  '$key': Offset(${value.dx.toStringAsFixed(1)}, ${value.dy.toStringAsFixed(1)}),");
    });
    buffer.writeln('};');
    developer.log(buffer.toString(), name: 'FlowchartViewer');
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
      ..color = Colors.purple
      ..strokeWidth = 3.0;

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
          ..color = Colors.purple
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