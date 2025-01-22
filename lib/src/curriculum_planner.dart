import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurriculumPlanner extends StatelessWidget {
  const CurriculumPlanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurriculumProvider(),
      child: Column(
        children: [
          Expanded(child: CourseGrid()),
          const Divider(),
          Expanded(child: QuarterPlanner()),
        ],
      ),
    );
  }
}

class CourseGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurriculumProvider>(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: provider.courses.length,
      itemBuilder: (context, index) {
        final course = provider.courses[index];
        return Draggable<String>(
          data: course,
          child: CourseBubble(course: course),
          feedback: CourseBubble(course: course, isDragging: true),
          childWhenDragging: const SizedBox.shrink(),
        );
      },
    );
  }
}

class QuarterPlanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurriculumProvider>(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: provider.quarters.length,
      itemBuilder: (context, index) {
        final quarter = provider.quarters[index];
        return DragTarget<String>(
          onAccept: (course) => provider.addCourseToQuarter(course, index),
          builder: (context, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.grey.shade200,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Q${index + 1}'),
                  ...quarter.map((course) => Text(course)).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CourseBubble extends StatelessWidget {
  final String course;
  final bool isDragging;

  const CourseBubble({required this.course, this.isDragging = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.shade200 : Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(child: Text(course, style: const TextStyle(color: Colors.white))),
    );
  }
}

class CurriculumProvider extends ChangeNotifier {
  final List<String> courses = ['Math 101', 'Physics 102', 'ME 201', 'ME 202'];
  final List<List<String>> quarters = List.generate(12, (_) => []);

  void addCourseToQuarter(String course, int quarterIndex) {
    quarters[quarterIndex].add(course);
    notifyListeners();
  }
}
