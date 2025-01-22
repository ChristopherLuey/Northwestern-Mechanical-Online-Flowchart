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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
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
          title: const Text(
            'Mechanical Engineering Curriculum',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Find the FlowchartViewer's state and reset it
                final flowchartViewerState = context.findAncestorStateOfType<FlowchartViewerState>();
                flowchartViewerState?.resetFlowchart();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings page
              },
            ),
          ],
          bottom: const TabBar(
            indicatorWeight: 2.0,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: EdgeInsets.symmetric(vertical: 0.0),
            tabs: [
              Tab(text: 'Flowchart Viewer'),
              Tab(text: 'Curriculum Planner'),
            ],
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: TabBarView(
            children: [
              FlowchartViewer(),
              CurriculumPlanner(),
            ],
          ),
        ),
      ),
    );
  }
}
