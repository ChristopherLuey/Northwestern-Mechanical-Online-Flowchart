import 'dart:ui';

class CourseInfo {
  final String name;
  int year;
  final List<String> prerequisites;
  final String term;
  final Offset originalPosition;
  final String title;
  final String full_title;
  final String description;
  final String link;
  String term_taking;

  CourseInfo({
    required this.name,
    required this.title,
    required this.full_title,
    this.year = 1,
    required this.prerequisites,
    required this.term,
    required this.originalPosition,
    required this.description,
    required this.link,
    this.term_taking = 'Not Set',
  });
}

final Map<String, CourseInfo> courses = {
  'GEN_ENG 205-1': CourseInfo(
    name: 'GEN_ENG 205-1',
    title: 'Eng Analysis I',
    full_title: 'Engineering Analysis I',
    year: 1,
    prerequisites: [],
    term: '[FW ]',
    description: 'Introduction to engineering analysis techniques, including linear algebra and programming applications.',
    originalPosition: Offset(63, 63),
    link: 'https://northwestern.edu/courses/GEN_ENG-205-1',
  ),
  'MATH 220-1': CourseInfo(
    name: 'MATH 220-1',
    title: 'Single Var Diff Calc',
    full_title: 'Single Variable Differential Calculus',
    year: 1,
    prerequisites: [],
    term: '[FW ]',
    description: 'Introduction to differential calculus for single-variable functions.',
    originalPosition: Offset(378, 63),
    link: 'https://northwestern.edu/courses/MATH-220-1',
  ),
  'PHYSICS 135-2/136-2': CourseInfo(
    name: 'PHYSICS 135-2/136-2',
    title: 'E&M',
    full_title: 'Electricity and Magnetism',
    year: 2,
    prerequisites: ['MATH 220-1', 'GEN_ENG 205-3'],
    term: '[FW ]',
    description: 'Covers electromagnetism, electric fields, and circuits with associated laboratory components.',
    originalPosition: Offset(935.4, 0.0),
    link: 'https://northwestern.edu/courses/PHYSICS-135-2',
  ),
  'MATH 220-2': CourseInfo(
    name: 'MATH 220-2',
    title: 'Single Var Int Calc',
    full_title: 'Single Variable Integral Calculus',
    year: 1,
    prerequisites: ['MATH 220-1'],
    term: '[FWS]',
    description: 'Covers integral calculus for single-variable functions and applications.',
    originalPosition: Offset(68.6, 281.2),
    link: 'https://northwestern.edu/courses/MATH-220-2',
  ),
  'GEN_ENG 205-2': CourseInfo(
    name: 'GEN_ENG 205-2',
    title: 'Eng Analysis II',
    full_title: 'Engineering Analysis II',
    year: 1,
    prerequisites: ['GEN_ENG 205-1', 'MATH 220-1'],
    term: '[ WS]',
    description: 'Continuation of engineering analysis, including Fourier transforms and numerical methods.',
    originalPosition: Offset(649.1, 177.1),
    link: 'https://northwestern.edu/courses/GEN_ENG-205-2',
  ),
  'PHYSICS 135-3/136-3': CourseInfo(
    name: 'PHYSICS 135-3/136-3',
    title: 'Waves and Motion',
    full_title: 'Waves and Oscillatory Motion',
    year: 2,
    prerequisites: ['PHYSICS 135-2/136-2'],
    term: '[ WS]',
    description: 'Focuses on wave phenomena, oscillatory motion, and their applications.',
    originalPosition: Offset(1489.3, 0.0),
    link: 'https://northwestern.edu/courses/PHYSICS-135-3',
  ),
  'GEN_ENG 205-3': CourseInfo(
    name: 'GEN_ENG 205-3',
    title: 'Eng Analysis III',
    full_title: 'Engineering Analysis III',
    year: 1,
    prerequisites: ['GEN_ENG 205-2'],
    term: '[F S]',
    description: 'Advanced engineering analysis techniques, including complex variables and differential equations.',
    originalPosition: Offset(651.6, 416.9),
    link: 'https://northwestern.edu/courses/GEN_ENG-205-3',
  ),
  'MECH_ENG 222': CourseInfo(
    name: 'MECH_ENG 222',
    title: 'Thermo I',
    full_title: 'Thermodynamics I',
    year: 2,
    prerequisites: ['GEN_ENG 205-3'],
    term: '[ W ]',
    description: 'Introduction to thermodynamics, covering the laws of thermodynamics and energy systems.',
    originalPosition: Offset(962.4, 404.7),
    link: 'https://northwestern.edu/courses/MECH_ENG-222',
  ),
  'CIV_ENV 216': CourseInfo(
    name: 'CIV_ENV 216',
    title: 'Mech. of Materials',
    full_title: 'Mechanics of Materials',
    year: 2,
    prerequisites: ['GEN_ENG 205-2'],
    term: '[FWS]',
    description: 'Study of material strength, deformation, and failure in engineering applications.',
    originalPosition: Offset(1180.1, 304.9),
    link: 'https://northwestern.edu/courses/CIV_ENV-216',
  ),
  'MECH_ENG 224': CourseInfo(
    name: 'MECH_ENG 224',
    title: 'Sci Embed Prog Python',
    full_title: 'Scientific Embedded Programming with Python',
    year: 2,
    prerequisites: ['GEN_ENG 205-2'],
    term: '[ WS]',
    description: 'Introduction to scientific programming and embedded systems using Python.',
    originalPosition: Offset(1167.7, 122.2),
    link: 'https://northwestern.edu/courses/MECH_ENG-224',
  ),
  'GEN_ENG 205-4': CourseInfo(
    name: 'GEN_ENG 205-4',
    title: 'Eng Analysis IV',
    full_title: 'Engineering Analysis IV',
    year: 2,
    prerequisites: ['GEN_ENG 205-3', 'MATH 220-2'],
    term: '[FW ]',
    description: 'Final course in the engineering analysis series, focusing on advanced numerical methods.',
    originalPosition: Offset(371.7, 415.7),
    link: 'https://northwestern.edu/courses/GEN_ENG-205-4',
  ),
  'MATH 228-1': CourseInfo(
    name: 'MATH 228-1',
    title: 'Multivar Diff Calc',
    full_title: 'Multivariable Differential Calculus',
    year: 1,
    prerequisites: ['MATH 220-2'],
    term: '[FWS]',
    description: 'Introduction to multivariable differential calculus and applications in engineering.',
    originalPosition: Offset(69.6, 491.8),
    link: 'https://northwestern.edu/courses/MATH-228-1',
  ),
  'MATH 228-2': CourseInfo(
    name: 'MATH 228-2',
    title: 'Multivar Int Calc',
    full_title: 'Multivariable Integral Calculus',
    year: 1,
    prerequisites: ['MATH 228-1'],
    term: '[FWS]',
    description: 'Covers multivariable integral calculus and related applications.',
    originalPosition: Offset(71.5, 691.1),
    link: 'https://northwestern.edu/courses/MATH-228-2',
  ),
  'MECH_ENG 240': CourseInfo(
    name: 'MECH_ENG 240',
    title: 'Mech Design & Manufacturing',
    full_title: 'Mechanical Design and Manufacturing',
    year: 2,
    prerequisites: ['CIV_ENV 216', 'MAT_SCI 201'],
    term: '[  S]',
    description: 'Covers the fundamentals of mechanical design and manufacturing processes.',
    originalPosition: Offset(1648.3, 118.1),
    link: 'https://northwestern.edu/courses/MECH_ENG-240',
  ),
  'MECH_ENG 315': CourseInfo(
    name: 'MECH_ENG 315',
    title: 'Thry of Machines: Dsgn of Elements',
    full_title: 'Theory of Machines: Design of Elements',
    year: 3,
    prerequisites: ['MECH_ENG 240'],
    term: '[F S]',
    description: 'Explores machine design principles and component-level analysis.',
    originalPosition: Offset(1671.3, 480.5),
    link: 'https://northwestern.edu/courses/MECH_ENG-315',
  ),
  'MECH_ENG 340-1': CourseInfo(
    name: 'MECH_ENG 340-1',
    title: 'Manuf Processes',
    full_title: 'Manufacturing Processes',
    year: 3,
    prerequisites: ['MECH_ENG 240'],
    term: '[F  ]',
    description: 'Study of modern manufacturing processes, including automation and material processing.',
    originalPosition: Offset(1400.8, 470.8),
    link: 'https://northwestern.edu/courses/MECH_ENG-340-1',
  ),
  'MECH_ENG 241': CourseInfo(
    name: 'MECH_ENG 241',
    title: 'Fluid Mech',
    full_title: 'Fluid Mechanics',
    year: 2,
    prerequisites: ['MATH 228-2', 'GEN_ENG 205-4'],
    term: '[F S]',
    description: 'Introduction to the principles of fluid mechanics, including fluid properties and dynamics.',
    originalPosition: Offset(386.0, 690.8),
    link: 'https://northwestern.edu/courses/MECH_ENG-241',
  ),
  'MECH_ENG 377': CourseInfo(
    name: 'MECH_ENG 377',
    title: 'Heat Transfer',
    full_title: 'Heat Transfer',
    year: 3,
    prerequisites: ['MECH_ENG 241'],
    term: '[ WS]',
    description: 'Study of heat transfer methods, including conduction, convection, and radiation.',
    originalPosition: Offset(757.7, 805.8),
    link: 'https://northwestern.edu/courses/MECH_ENG-377',
  ),
  'MECH_ENG 390': CourseInfo(
    name: 'MECH_ENG 390',
    title: 'Intro to Dynamic Systems',
    full_title: 'Introduction to Dynamic Systems',
    year: 3,
    prerequisites: ['CIV_ENV 216', 'MECH_ENG 377'],
    term: '[F  ]',
    description: 'Introduction to dynamic systems, including modeling and simulation techniques.',
    originalPosition: Offset(1138.3, 587.7),
    link: 'https://northwestern.edu/courses/MECH_ENG-390',
  ),
  'MECH_ENG 314': CourseInfo(
    name: 'MECH_ENG 314',
    title: 'Dynamics',
    full_title: 'Dynamics',
    year: 3,
    prerequisites: ['GEN_ENG 205-4'],
    term: '[F S]',
    description: 'Comprehensive study of dynamics, including kinematics and kinetics of particles and rigid bodies.',
    originalPosition: Offset(761.0, 609.6),
    link: 'https://northwestern.edu/courses/MECH_ENG-314',
  ),
  'MECH_ENG 233': CourseInfo(
    name: 'MECH_ENG 233',
    title: 'Electronics Design',
    full_title: 'Electronics Design',
    year: 2,
    prerequisites: [],
    term: '[F  ]',
    description: 'Introduction to electronics design principles, including circuit analysis and PCB design.',
    originalPosition: Offset(1041.8, 832.9),
    link: 'https://northwestern.edu/courses/MECH_ENG-233',
  ),
  'COMM_ST 102': CourseInfo(
    name: 'COMM_ST 102',
    title: 'Or PERF_ST 103 or PERF_ST 203',
    full_title: 'Public Speaking',
    year: 3,
    prerequisites: [],
    term: '[FWS]',
    description: 'Covers public speaking techniques, communication theory, and effective presentation skills.',
    originalPosition: Offset(1296.5, 828.1),
    link: 'https://northwestern.edu/courses/COMM_ST-102',
  ),
  'DSGN 106-1': CourseInfo(
    name: 'DSGN 106-1',
    title: 'Dsgn Thinking and Communication I',
    full_title: 'Design Thinking and Communication I',
    year: 1,
    prerequisites: [],
    term: '[FW ]',
    description: 'Introduction to design thinking and effective communication in engineering contexts.',
    originalPosition: Offset(1842.4, 634.0),
    link: 'https://northwestern.edu/courses/DSGN-106-1',
  ),
  'DSGN 106-2': CourseInfo(
    name: 'DSGN 106-2',
    title: 'Dsgn Thinking and Communication II',
    full_title: 'Design Thinking and Communication II',
    year: 1,
    prerequisites: ['DSGN 106-1'],
    term: '[  S]',
    description: 'Continuation of design thinking with a focus on team-based projects and presentations.',
    originalPosition: Offset(1578.2, 811.1),
    link: 'https://northwestern.edu/courses/DSGN-106-2',
  ),
  'MECH_ENG 398-1': CourseInfo(
    name: 'MECH_ENG 398-1',
    title: 'Engineering Dsgn',
    full_title: 'Engineering Design I',
    year: 4,
    prerequisites: [],
    term: '[FW ]',
    description: 'Capstone engineering design course, focusing on project development and execution.',
    originalPosition: Offset(210.4, 926.8),
    link: 'https://northwestern.edu/courses/MECH_ENG-398-1',
  ),
  'MECH_ENG 398-2': CourseInfo(
    name: 'MECH_ENG 398-2',
    title: 'Engineering Dsgn',
    full_title: 'Engineering Design II',
    year: 4,
    prerequisites: ['MECH_ENG 398-1'],
    term: '[ WS]',
    description: 'Continuation of the capstone design project, with emphasis on final deliverables and presentation.',
    originalPosition: Offset(559.6, 922.7),
    link: 'https://northwestern.edu/courses/MECH_ENG-398-2',
  ),
  'CHEM 131/141': CourseInfo(
    name: 'CHEM 131/141',
    title: 'Or CHEM 151/161 or CHEM 171/181',
    full_title: 'General Chemistry with Lab',
    year: 1,
    prerequisites: [],
    term: '[FWS]',
    description: 'Introduction to chemistry principles with laboratory experiments.',
    originalPosition: Offset(2027.0, 456.7),
    link: 'https://northwestern.edu/courses/CHEM-131',
  ),
  'MAT_SCI 201': CourseInfo(
    name: 'MAT_SCI 201',
    title: 'Materials Science',
    full_title: 'Introduction to Materials Science',
    year: 2,
    prerequisites: ['CHEM 131/141'],
    term: '[FWS]',
    description: 'Covers the properties and behavior of materials in engineering applications.',
    originalPosition: Offset(1831.9, 278.3),
    link: 'https://northwestern.edu/courses/MAT_SCI-201',
  ),
};
