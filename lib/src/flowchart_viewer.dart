import 'package:flutter/material.dart';
import 'course_box.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:developer' as developer;
import 'course_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'curriculum_planner.dart';
import 'package:provider/provider.dart';

final Size globalCanvasSize = Size(8000, 5000); // Global canvas size

class FlowchartViewer extends StatefulWidget {
  const FlowchartViewer({Key? key}) : super(key: key);

  @override
  FlowchartViewerState createState() => FlowchartViewerState();
}

class FlowchartViewerState extends State<FlowchartViewer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Size courseBoxSize = Size(200, 100);

  Map<String, Offset> positions = {};

  Offset panOffset = Offset.zero;
  double scale = 1.0;

  String? selectedCourse;

  @override
  void initState() {
    super.initState();
    _initializeFlowchart();
  }

  void _initializeFlowchart() {
    positions = courses.map((key, courseInfo) => MapEntry(key, courseInfo.originalPosition));
    positions.forEach((key, value) {
      developer.log('Initial position of $key: $value', name: 'FlowchartViewer');
    });
  }

  void resetFlowchart() {
    setState(() {
      _initializeFlowchart();
    });
  }

  void _onTermSelected(String course, String term, int year) {
    final courseInfo = courses[course];
    if (courseInfo != null) {
      setState(() {
        final provider = Provider.of<CurriculumProvider>(context, listen: false);

        // Remove the course from the previous term if it was set
        if (courseInfo.term_taking != "Not Set" && courseInfo.term_taking != '🚫') {
          provider.removeCourseFromTerm(courseInfo, courseInfo.year, courseInfo.term_taking);
        }

        // Update the course with the new term and year
        courseInfo.term_taking = term == '🚫' ? "Not Set" : term;
        courseInfo.year = year;

        // Assign the course to the new term if it's not '🚫'
        if (term != '🚫') {
          provider.assignCourseToTerm(courseInfo, year, term);
        }
      });
    }
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
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..translate(panOffset.dx, panOffset.dy)
                          ..scale(scale),
                        child: Stack(
                          children: <Widget>[
                            CustomPaint(
                              size: Size.infinite,
                              painter: FlowchartPainter(positions, courseBoxSize, courses),
                            ),
                            ...positions.entries.map((entry) {
                              final courseInfo = courses[entry.key]!;
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
                                      final newPosition = entry.value + details.delta * 3.0;
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
                                      title: courseInfo.name,
                                      subtitle: courseInfo.title,
                                      term: courseInfo.term,
                                      year: courseInfo.year,
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
              heroTag: 'resetButton',
              onPressed: () {
                setState(() {
                  resetFlowchart(); // Reset positions when button is pressed
                });
              },
              child: Icon(Icons.refresh),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'plannerButton',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CurriculumPlanner()),
                );
              },
              child: Icon(Icons.schedule),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'addButton',
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
              heroTag: 'saveButton',
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
    final courseInfo = courses[selectedCourse];
    return Drawer(
      width: 325.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            title: Text(courseInfo?.name ?? '', style: TextStyle(fontSize: 18.0)),
            automaticallyImplyLeading: false,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${courseInfo?.full_title ?? ''}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                SizedBox(height: 8.0),
                Text('Terms Offered: ${courseInfo?.term ?? ''}', style: TextStyle(fontSize: 16.0)),
                SizedBox(height: 8.0),
                Text('Year: ${courseInfo?.year ?? ''}', style: TextStyle(fontSize: 16.0)),
                Row(
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _onTermSelected(selectedCourse!, courseInfo!.term_taking, index + 1);
                        },
                        child: Text('${index + 1}'),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8.0),
                Text('Planned Term: ${courseInfo?.term_taking ?? 'Not Set'}', style: TextStyle(fontSize: 16.0)),
                Row(
                  children: ['F', 'W', 'S', '🚫'].map((term) {
                    final isAvailable = term == '🚫' || (courseInfo?.term.contains(term) ?? false);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        onPressed: isAvailable
                            ? () => _onTermSelected(selectedCourse!, term, courseInfo!.year)
                            : null,
                        child: Text(term),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? null : Colors.grey, // Gray out if not available
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.0),
                Text('Prerequisites: ${courseInfo?.prerequisites.join(', ') ?? 'None'}', style: TextStyle(fontSize: 16.0)),
                SizedBox(height: 8.0),
                Text('Description: ${courseInfo?.description ?? ''}', style: TextStyle(fontSize: 16.0)),
                SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () async {
                    if (courseInfo?.link != null) {
                      final url = Uri.parse(courseInfo!.link);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        developer.log('Could not launch ${courseInfo.link}', name: 'FlowchartViewer');
                      }
                    }
                  },
                  child: Text(
                    'More Info',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16.0),
                  ),
                ),
              ],
            ),
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
  final Map<String, CourseInfo> courses;

  FlowchartPainter(this.positions, this.courseBoxSize, this.courses);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 3.0;

    for (var entry in courses.entries) {
      final course = entry.key;
      final prereqs = entry.value.prerequisites;

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