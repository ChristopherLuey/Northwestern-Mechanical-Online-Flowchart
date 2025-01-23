import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'course_info.dart'; // Import the CourseInfo class

class CurriculumPlanner extends StatelessWidget {
  const CurriculumPlanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurriculumProvider>(context);

    return Scaffold(
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
          Expanded(child: QuarterPlanner()),
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
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurriculumProvider>(context);
    for (int i = 0; i < provider.quarters.length; i++) {
      developer.log('Quarter $i: ${provider.quarters[i]}', name: 'QuarterPlanner');
    }
    return Column(
      children: [
        Row(
          children: const [
            SizedBox(width: 50), // Placeholder for year label
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0), // Added bottom padding
                  child: Text('Fall', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0), // Added bottom padding
                  child: Text('Winter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0), // Added bottom padding
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
                padding: const EdgeInsets.symmetric(vertical: 10.0), // Added vertical padding
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0), // Increased right padding
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Year ${rowIndex + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // Increased font size
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5, // Reduced main axis spacing
                          childAspectRatio: 2, // Adjusted aspect ratio to make boxes shorter
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final quarterIndex = rowIndex * 3 + index;
                          if (quarterIndex >= provider.quarters.length) return Container();
                          return Padding(
                            padding: const EdgeInsets.all(8.0), // Added padding around each box
                            child: DragTarget<CourseInfo>(
                              onAccept: (courseInfo) => provider.addCourseToQuarter(courseInfo, quarterIndex),
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(15), // Match rounded corners
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start, // Align to top
                                    children: provider.quarters[quarterIndex]
                                        .map((courseInfo) {
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: CourseBubble(courseInfo: courseInfo),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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

class CourseBubble extends StatelessWidget {
  final CourseInfo courseInfo;
  final bool isDragging;

  const CourseBubble({required this.courseInfo, this.isDragging = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.shade200 : Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(child: Text(courseInfo.name, style: const TextStyle(color: Colors.white))),
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
}
