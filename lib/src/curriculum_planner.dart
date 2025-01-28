import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'course_info.dart'; // Import the CourseInfo class
import 'course_box.dart'; // Import the CourseBox from course_box.dart
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class CurriculumPlanner extends StatefulWidget {
  const CurriculumPlanner({Key? key}) : super(key: key);

  @override
  _CurriculumPlannerState createState() => _CurriculumPlannerState();
}

class _CurriculumPlannerState extends State<CurriculumPlanner> {
  String? selectedCourse;

  void _onCourseBoxTap(CourseInfo courseInfo) {
    setState(() {
      selectedCourse = courseInfo.name;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildCoursePanel(Map<String, CourseInfo> courses) {
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
                          _onTermSelected(courseInfo!, courseInfo!.term_taking, index + 1); // Replace 'Term' with appropriate term if needed
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
                            ? () => _onTermSelected(courseInfo!, term, courseInfo!.year) // Pass courseInfo instead of selectedCourse
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
                      if (await canLaunch(url.toString())) {
                        await launch(url.toString());
                      } else {
                        developer.log('Could not launch ${courseInfo.link}', name: 'CurriculumPlanner');
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

  void _onTermSelected(CourseInfo courseInfo, String term, int year) async {
    final isRemoving = term == '🚫';
    final provider = Provider.of<CurriculumProvider>(context, listen: false);

    if (!isRemoving) {
      // Check prerequisites
      final unmetPrereqs = courseInfo.prerequisites.where((prereqName) {
        final prereq = courses[prereqName];
        return prereq != null && provider.hasUnmetPrerequisites(courseInfo, year, term);
      }).toList();

      if (unmetPrereqs.isNotEmpty) {
        final proceed = await _showPrerequisiteWarning(context, unmetPrereqs, courseInfo);
        if (!proceed) return;
      }
    }

    setState(() {
      // Remove from previous term if it was set
      if (courseInfo.term_taking != "Not Set" && courseInfo.term_taking != '🚫') {
        provider.removeCourseFromTerm(courseInfo, courseInfo.year, courseInfo.term_taking);
      }

      courseInfo.term_taking = term != '🚫' ? term : 'Not Set';
      courseInfo.year = year;
      
      // Only add to new term if not removing
      if (term != '🚫') {
        provider.assignCourseToTerm(courseInfo, year, term);
      }
      
      provider.updateCourse(courseInfo);
    });

    if (isRemoving) {
      final dependentCourses = provider.getCoursesDependingOn(courseInfo.name);
      if (dependentCourses.isNotEmpty) {
        final proceed = await _showDependentCoursesWarning(context, dependentCourses, courseInfo);
        if (!proceed) return;
      }
    }
  }

  Future<bool> _showPrerequisiteWarning(BuildContext context, List<String> unmetPrereqs, CourseInfo course) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prerequisite Warning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('The following prerequisites for ${course.name} are not met:'),
            SizedBox(height: 10),
            Column(
              children: unmetPrereqs.map((p) => Text('- $p')).toList(),
            ),
            SizedBox(height: 20),
            Text('Do you want to proceed anyway?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Proceed'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDependentCoursesWarning(BuildContext context, List<CourseInfo> dependentCourses, CourseInfo course) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dependency Warning'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Removing ${course.name} affects these dependent courses:'),
            SizedBox(height: 10),
            Column(
              children: dependentCourses.map((c) => Text('- ${c.name}')).toList(),
            ),
            SizedBox(height: 20),
            Text('Do you want to proceed anyway?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Proceed'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurriculumProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: selectedCourse != null ? _buildCoursePanel(courses) : null,
      onDrawerChanged: (isOpen) {
        if (!isOpen) {
          setState(() {
            selectedCourse = null; // Reset the selected course when drawer is closed
            developer.log('Drawer closed, selected course reset to null', name: 'CurriculumPlanner');
          });
        }
      },
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mechanical Engineering Curriculum Planner',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          const Divider(),
          Expanded(child: QuarterPlanner(onCourseBoxTap: _onCourseBoxTap)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Navigate back to the previous screen
        },
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class QuarterPlanner extends StatelessWidget {
  final Function(CourseInfo) onCourseBoxTap;

  const QuarterPlanner({Key? key, required this.onCourseBoxTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurriculumProvider>(context);
    return Column(
      children: [
        Row(
          children: const [
            SizedBox(width: 50), // Placeholder for year label
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Fall', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Winter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Spring', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: (provider.quarters.length / 3).ceil(),
            itemBuilder: (context, rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Year ${rowIndex + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: List.generate(3, (index) {
                          final quarterIndex = rowIndex * 3 + index;
                          if (quarterIndex >= provider.quarters.length) return Expanded(child: Container());
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                constraints: BoxConstraints(minHeight: 150), // Set a minimum height
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DragTarget<CourseInfo>(
                                  onAccept: (courseInfo) => provider.addCourseToQuarter(courseInfo, quarterIndex),
                                  builder: (context, candidateData, rejectedData) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        ...provider.quarters[quarterIndex].map((courseInfo) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: CourseBox(
                                              title: courseInfo.name,
                                              subtitle: courseInfo.title,
                                              term: courseInfo.term,
                                              year: courseInfo.year,
                                              term_taking: courseInfo.term_taking,
                                              textAlign: TextAlign.left,
                                              isCurriculumPlanner: true,
                                              onTap: () => onCourseBoxTap(courseInfo),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CurriculumProvider extends ChangeNotifier {
  final List<List<CourseInfo>> quarters = List.generate(12, (_) => []);

  CurriculumProvider() {
    developer.log('CurriculumProvider initialized', name: 'CurriculumProvider');
  }

  void addCourseToQuarter(CourseInfo courseInfo, int quarterIndex) {
    quarters[quarterIndex].insert(0, courseInfo); // Insert CourseInfo at the beginning
    developer.log('Added course ${courseInfo.name} to quarter $quarterIndex: ${quarters[quarterIndex]}', name: 'CurriculumProvider');
    notifyListeners();
  }

  void assignCourseToTerm(CourseInfo courseInfo, int year, String term) {
    int quarterIndex;
    developer.log('Assigning course ${courseInfo.name} to term $term in year $year', name: 'CurriculumProvider');
    switch (term) {
      case 'F':
        quarterIndex = (year - 1) * 3;
        break;
      case 'W':
        quarterIndex = (year - 1) * 3 + 1;
        break;
      case 'S':
        quarterIndex = (year - 1) * 3 + 2;
        break;
      default:
        return;
    }

    developer.log('a course ${courseInfo.name} to term $term in year $year', name: 'CurriculumProvider');
    // Ensure the course is not already in the quarter before adding
    if (!quarters[quarterIndex].contains(courseInfo)) {
      quarters[quarterIndex].add(courseInfo);
      notifyListeners();
      developer.log('Quarter $quarterIndex: ${quarters[quarterIndex]}', name: 'CurriculumProvider');
    }
  }

  void removeCourseFromTerm(CourseInfo courseInfo, int year, String term) {
    int quarterIndex;
    switch (term) {
      case 'F':
        quarterIndex = (year - 1) * 3;
        break;
      case 'W':
        quarterIndex = (year - 1) * 3 + 1;
        break;
      case 'S':
        quarterIndex = (year - 1) * 3 + 2;
        break;
      default:
        return;
    }
    if (quarters[quarterIndex].contains(courseInfo)) {
      quarters[quarterIndex].remove(courseInfo);
      notifyListeners();
      developer.log('Removed course ${courseInfo.name} from quarter $quarterIndex: ${quarters[quarterIndex]}', name: 'CurriculumProvider');
    }
  }

  List<CourseInfo> getCoursesDependingOn(String courseName) {
    return quarters.expand((quarter) => quarter).where((course) {
      return course.prerequisites.contains(courseName);
    }).toList();
  }

  bool hasUnmetPrerequisites(CourseInfo course, int targetYear, String targetTerm) {
    final targetQuarterIndex = _getQuarterIndex(targetYear, targetTerm);
    
    for (final prereqName in course.prerequisites) {
      final prereq = courses[prereqName];
      if (prereq == null) continue;
      
      if (prereq.term_taking == 'Not Set' || prereq.term_taking == '🚫') {
        return true;
      }
      
      final prereqQuarterIndex = _getQuarterIndex(prereq.year, prereq.term_taking);
      if (prereqQuarterIndex >= targetQuarterIndex) {
        return true;
      }
    }
    return false;
  }

  int _getQuarterIndex(int year, String term) {
    switch (term) {
      case 'F': return (year - 1) * 3;
      case 'W': return (year - 1) * 3 + 1;
      case 'S': return (year - 1) * 3 + 2;
      default: return -1;
    }
  }

  void updateCourse(CourseInfo courseInfo) {
    // Implementation of updateCourse method
  }

  void removeCourseFromPlanner(String courseName) {
    // Remove from all quarters
    for (var quarter in quarters) {
      quarter.removeWhere((course) => course.name == courseName);
    }
    notifyListeners();
  }
}
