import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flowchart_viewer.dart';
import 'curriculum_planner.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_service.dart';
import 'course_box.dart';

void main() {
  final settingsController = SettingsController(SettingsService());
  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Curriculum Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mechanical Engineering Curriculum'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.view_module), text: 'Flowchart Viewer'),
              Tab(icon: Icon(Icons.edit), text: 'Curriculum Planner'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FlowchartViewer(),
            CurriculumPlanner(),
          ],
        ),
      ),
    );
  }
}
