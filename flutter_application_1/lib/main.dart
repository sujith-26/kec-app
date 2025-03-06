import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io' show File, Platform, Directory;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:ui_web' as ui;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:google_fonts/google_fonts.dart';

void registerViewFactory(String viewType, String url) {
  if (kIsWeb) {
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });
    debugPrint('Registered view factory for $viewType with URL: $url');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final tz.Location local = tz.getLocation('Asia/Kolkata');
  tz.setLocalLocation(local);
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  String? deviceId = prefs.getString('deviceId');
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await prefs.setString('deviceId', deviceId);
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(KECStudyHubApp(isDarkMode: isDarkMode, deviceId: deviceId));
}

class KECStudyHubApp extends StatelessWidget {
  final bool isDarkMode;
  final String deviceId;

  const KECStudyHubApp(
      {super.key, required this.isDarkMode, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KEC Study Hub',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White background
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: const Color(0xFF00246B), // Dark Blue for text
          displayColor: const Color(0xFF00246B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00246B), // Dark Blue
          elevation: 0,
          foregroundColor: Color(0xFFFFFFFF), // White
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCADCFC), // Light Blue
            foregroundColor: const Color(0xFF00246B), // Dark Blue
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shadowColor: Colors.black26,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00246B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCADCFC), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: GoogleFonts.poppins(color: const Color(0xFF00246B)),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.black26,
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // White background
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: const Color(0xFF00246B),
          displayColor: const Color(0xFF00246B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00246B), // Dark Blue
          elevation: 0,
          foregroundColor: Color(0xFFFFFFFF),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCADCFC), // Light Blue
            foregroundColor: const Color(0xFF00246B), // Dark Blue
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shadowColor: Colors.black26,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00246B)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCADCFC), width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: GoogleFonts.poppins(color: const Color(0xFF00246B)),
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: Colors.black26,
          color: Colors.grey[850],
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_emailController.text.endsWith('@kongu.edu')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only @kongu.edu emails are allowed')),
        );
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      debugPrint('Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Login successful, token: ${data['token']}');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['name']);
        await prefs.setString('userEmail', data['email']);
        await prefs.setString('token', data['token']);
        if (!mounted) return;
        if (_emailController.text == 'admin@kongu.edu') {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  AdminPage(token: data['token']),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeScreen(
                deviceId: prefs.getString('deviceId') ?? '',
                token: data['token'],
                userName: data['name'],
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCADCFC), // Light Blue
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school,
                        size: 50, color: Color(0xFF00246B)),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'KEC Study Hub',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00246B), // Dark Blue
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: const Color(0xFF00246B)),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    style: GoogleFonts.poppins(color: const Color(0xFF00246B)),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF00246B)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    style: GoogleFonts.poppins(color: const Color(0xFF00246B)),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF00246B)),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),
                  AnimatedScaleButton(
                    onPressed: _login,
                    child:
                        Text('Login', style: GoogleFonts.poppins(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  final String token;

  const AdminPage({super.key, required this.token});

  @override
  State<AdminPage> createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    if (!_emailController.text.endsWith('@kongu.edu')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only @kongu.edu emails are allowed')),
        );
      }
      return;
    }

    try {
      debugPrint('Adding student with token: ${widget.token}');
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/users/add-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token.trim()}',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        }),
      );
      debugPrint(
          'Add student response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student added: ${data['email']}')),
          );
        }
        _nameController.clear();
        _emailController.clear();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed: ${jsonDecode(response.body)['message']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _bulkAddStudents() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.bytes != null) {
        final csvString = String.fromCharCodes(result.files.single.bytes!);
        final lines = csvString.split('\n');
        final students =
            lines.skip(1).where((line) => line.trim().isNotEmpty).map((line) {
          final parts = line.split(',');
          return {'name': parts[0].trim(), 'email': parts[1].trim()};
        }).toList();

        debugPrint('Bulk adding students with token: ${widget.token}');
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/users/bulk-add-users'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token.trim()}',
          },
          body: jsonEncode({'students': students}),
        );
        debugPrint(
            'Bulk add response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Bulk add completed: ${data['results'].length} students added')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Bulk add failed: ${jsonDecode(response.body)['message']}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during bulk add: $e')),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.all(16.0), // Reduced padding to avoid overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Add Students',
                  style: GoogleFonts.poppins(
                    fontSize: 28, // Slightly reduced size
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00246B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage student accounts',
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: const Color(0xFF00246B)),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student Name',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF00246B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF00246B)),
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.person, color: Color(0xFF00246B)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Student Email',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF00246B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF00246B)),
                          decoration: const InputDecoration(
                            prefixIcon:
                                Icon(Icons.email, color: Color(0xFF00246B)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AnimatedScaleButton(
                                  onPressed: _addStudent,
                                  child: Text('Add Student',
                                      style: GoogleFonts.poppins(fontSize: 16)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AnimatedScaleButton(
                                  onPressed: _bulkAddStudents,
                                  child: Text('Bulk Add',
                                      style: GoogleFonts.poppins(fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String deviceId;
  final String token;
  final String userName;

  const HomeScreen(
      {super.key,
      required this.deviceId,
      required this.token,
      required this.userName});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _pages = [
      HomeDashboard(
          deviceId: widget.deviceId,
          token: widget.token,
          userName: widget.userName),
      ResourcesPage(deviceId: widget.deviceId, token: widget.token),
      UploadMaterialScreen(deviceId: widget.deviceId, token: widget.token),
      const DiscussionForumPagePlaceholder(),
      ProfilePage(
          deviceId: widget.deviceId,
          token: widget.token,
          userName: widget.userName),
    ];
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('isDarkMode') ?? false);
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('KEC Study Hub', style: GoogleFonts.poppins(fontSize: 20)),
            Text('Welcome, ${widget.userName}',
                style: GoogleFonts.poppins(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFFCADCFC), // Light Blue
        unselectedItemColor: const Color(0xFF00246B), // Dark Blue
        showUnselectedLabels: true,
        backgroundColor: const Color(0xFFFFFFFF), // White
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Resources'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Add Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  final String deviceId;
  final String token;
  final String userName;

  const HomeDashboard(
      {super.key,
      required this.deviceId,
      required this.token,
      required this.userName});

  @override
  State<HomeDashboard> createState() => HomeDashboardState();
}

class HomeDashboardState extends State<HomeDashboard> {
  List<StudyMaterial> recentlyViewed = [];
  List<StudyMaterial> pinnedResources = [];
  List<Map<String, dynamic>> examDates = [];
  List<Map<String, dynamic>> studyPlans = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentlyViewed =
          (jsonDecode(prefs.getString('recentlyViewed') ?? '[]') as List)
              .map((item) => StudyMaterial.fromJson(item))
              .toList();
      pinnedResources =
          (jsonDecode(prefs.getString('pinnedResources') ?? '[]') as List)
              .map((item) => StudyMaterial.fromJson(item))
              .toList();
      examDates = (jsonDecode(prefs.getString('examDates') ?? '[]') as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      studyPlans = (jsonDecode(prefs.getString('studyPlans') ?? '[]') as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    });
    await _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    for (var exam in examDates) {
      final date = DateTime.parse(exam['date']);
      if (date.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          exam.hashCode,
          'Exam Reminder: ${exam['name']}',
          'Prepare for ${exam['name']} on ${DateFormat('dd MMM yyyy').format(date)}',
          tz.TZDateTime.from(date.subtract(const Duration(days: 1)), tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'exam_channel',
              'Exam Reminders',
              channelDescription: 'Reminders for upcoming exams',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }

    for (var plan in studyPlans) {
      final date = DateTime.parse(plan['date']);
      if (date.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          plan.hashCode,
          'Study Plan: ${plan['task']}',
          'Reminder: ${plan['task']} today at ${plan['time']}',
          tz.TZDateTime.from(date, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'study_channel',
              'Study Plan Reminders',
              channelDescription: 'Daily study plan reminders',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  void _showResources(String title, List<StudyMaterial> resources) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceListScreen(
          title: title,
          resources: resources,
          token: widget.token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCard(
                  title: 'Recently Viewed',
                  icon: Icons.history,
                  content: recentlyViewed.isEmpty
                      ? Center(
                          child: Text('No recent views',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF00246B))))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: recentlyViewed.length > 3
                              ? 3
                              : recentlyViewed.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(recentlyViewed[index].subjectName,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00246B),
                                    fontSize: 14)),
                            subtitle: Text(recentlyViewed[index].department,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00246B),
                                    fontSize: 12)),
                          ),
                        ),
                  onTap: () =>
                      _showResources('Recently Viewed', recentlyViewed),
                ),
                _buildCard(
                  title: 'Pinned Resources',
                  icon: Icons.push_pin,
                  content: pinnedResources.isEmpty
                      ? Center(
                          child: Text('No pinned resources',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF00246B))))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: pinnedResources.length > 3
                              ? 3
                              : pinnedResources.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(pinnedResources[index].subjectName,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00246B),
                                    fontSize: 14)),
                            subtitle: Text(pinnedResources[index].department,
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00246B),
                                    fontSize: 12)),
                          ),
                        ),
                  onTap: () =>
                      _showResources('Pinned Resources', pinnedResources),
                ),
                _buildCard(
                  title: 'Exam Dates',
                  icon: Icons.calendar_today,
                  content: examDates.isEmpty
                      ? Center(
                          child: Text('No exams scheduled',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF00246B))))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              examDates.length > 3 ? 3 : examDates.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(examDates[index]['name'],
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00246B),
                                    fontSize: 14)),
                            subtitle: Text(
                              DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(examDates[index]['date'])),
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF00246B), fontSize: 12),
                            ),
                          ),
                        ),
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => _ExamDateDialog(),
                    );
                    if (result != null) {
                      setState(() => examDates.add(result));
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('examDates', jsonEncode(examDates));
                      await _scheduleNotifications();
                    }
                  },
                ),
                _buildCard(
                  title: 'Study Plan',
                  icon: Icons.book,
                  content: studyPlans.isEmpty
                      ? Center(
                          child: Text('No study plans',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF00246B))))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount:
                              studyPlans.length > 3 ? 3 : studyPlans.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(studyPlans[index]['task'],
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00246B),
                                    fontSize: 14)),
                            subtitle: Text(
                              '${studyPlans[index]['time']} - ${DateFormat('dd MMM').format(DateTime.parse(studyPlans[index]['date']))}',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF00246B), fontSize: 12),
                            ),
                          ),
                        ),
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => _StudyPlanDialog(),
                    );
                    if (result != null) {
                      setState(() => studyPlans.add(result));
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'studyPlans', jsonEncode(studyPlans));
                      await _scheduleNotifications();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget content,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF00246B), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00246B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

class ResourceListScreen extends StatelessWidget {
  final String title;
  final List<StudyMaterial> resources;
  final String token;

  const ResourceListScreen(
      {super.key,
      required this.title,
      required this.resources,
      required this.token});

  Future<void> _downloadFile(
      String url, String fileName, BuildContext context) async {
    try {
      debugPrint('Downloading file from: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Download response: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch file: HTTP ${response.statusCode}');
      }

      String extension = url.split('.').last.split('?')[0].toLowerCase();
      final sanitizedFileName = '$fileName.$extension';

      if (kIsWeb) {
        final blob = html.Blob([response.bodyBytes]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: blobUrl)
          ..setAttribute('download', sanitizedFileName)
          ..click();
        html.Url.revokeObjectUrl(blobUrl);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Downloading file... Check your browser downloads.')));
      } else {
        PermissionStatus status;
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          status = androidInfo.version.sdkInt >= 33
              ? await Permission.manageExternalStorage.request()
              : await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied.');
          }
        }

        Directory? directory = Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();
        if (Platform.isAndroid && !(await directory.exists())) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Downloads');
            if (!(await directory.exists())) {
              await directory.create(recursive: true);
            }
          }
        } else if (Platform.isIOS) {
          directory = Directory('${directory.path}/Downloads');
          if (!(await directory.exists())) {
            await directory.create(recursive: true);
          }
        }

        if (directory == null) {
          throw Exception('Failed to determine download directory');
        }
        final filePath = '${directory.path}/$sanitizedFileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('File downloaded to: $filePath');

        if (Platform.isIOS) {
          await Share.shareXFiles([XFile(filePath)],
              text: 'Downloaded file: $sanitizedFileName');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File downloaded to $filePath')));
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins()),
      ),
      body: resources.isEmpty
          ? Center(
              child: Text('No $title available',
                  style: GoogleFonts.poppins(color: const Color(0xFF00246B))))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final material = resources[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(material.subjectName,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF00246B))),
                    subtitle: Text(
                        '${material.department} • Uploaded by: ${material.uploadedBy}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF00246B))),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility,
                              color: Color(0xFF00246B)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MaterialPreviewScreen(
                                  material: material,
                                  onDownload: _downloadFile,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download,
                              color: Color(0xFF00246B)),
                          onPressed: () => _downloadFile(
                              material.fileUrl, material.subjectName, context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ExamDateDialog extends StatefulWidget {
  @override
  State<_ExamDateDialog> createState() => _ExamDateDialogState();
}

class _ExamDateDialogState extends State<_ExamDateDialog> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Exam Date',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: const Color(0xFF00246B))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Exam Name'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2026),
              );
              setState(() {});
            },
            child: Text(
              _selectedDate == null
                  ? 'Select Date'
                  : DateFormat('dd MMM yyyy').format(_selectedDate!),
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _selectedDate != null) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'date': _selectedDate!.toIso8601String(),
              });
            }
          },
          child: Text('Add', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

class _StudyPlanDialog extends StatefulWidget {
  @override
  State<_StudyPlanDialog> createState() => _StudyPlanDialogState();
}

class _StudyPlanDialogState extends State<_StudyPlanDialog> {
  final _taskController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Study Plan',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: const Color(0xFF00246B))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(labelText: 'Task'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2026),
              );
              setState(() {});
            },
            child: Text(
              _selectedDate == null
                  ? 'Select Date'
                  : DateFormat('dd MMM yyyy').format(_selectedDate!),
              style: GoogleFonts.poppins(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              setState(() {});
            },
            child: Text(
              _selectedTime == null
                  ? 'Select Time'
                  : _selectedTime!.format(context),
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          onPressed: () {
            if (_taskController.text.isNotEmpty &&
                _selectedDate != null &&
                _selectedTime != null) {
              final dateTime = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );
              Navigator.pop(context, {
                'task': _taskController.text,
                'date': dateTime.toIso8601String(),
                'time': _selectedTime!.format(context),
              });
            }
          },
          child: Text('Add', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}

class ResourcesPage extends StatefulWidget {
  final String deviceId;
  final String token;

  const ResourcesPage({super.key, required this.deviceId, required this.token});

  @override
  State<ResourcesPage> createState() => ResourcesPageState();
}

class ResourcesPageState extends State<ResourcesPage> {
  String selectedFilterDepartment = 'All';
  String? selectedYear;
  final List<String> departments = [
    'All',
    'CSE',
    'ECE',
    'Mech',
    'Civil',
    'EEE'
  ];
  final List<String> years = ['1', '2', '3', '4'];
  bool _isLoading = true;
  String? _errorMessage;
  List<StudyMaterial> _materials = [];
  List<StudyMaterial> pinnedResources = [];
  Map<String, List<String>> comments = {};

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
    _loadPinnedResources();
    _loadComments();
  }

  Future<void> _fetchMaterials() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      String url = 'http://localhost:5000/study-materials';
      List<String> queryParams = [];
      if (selectedFilterDepartment != 'All')
        queryParams.add('department=$selectedFilterDepartment');
      if (selectedYear != null) queryParams.add('year=$selectedYear');
      if (queryParams.isNotEmpty) url += '?${queryParams.join('&')}';
      debugPrint('Fetching materials from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      debugPrint('Fetch materials response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _materials =
              data.map((item) => StudyMaterial.fromJson(item)).toList();
        });
      } else {
        setState(() =>
            _errorMessage = 'Failed to load materials: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching materials: $e');
      setState(() => _errorMessage = 'Error fetching materials: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadPinnedResources() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pinnedResources =
          (jsonDecode(prefs.getString('pinnedResources') ?? '[]') as List)
              .map((item) => StudyMaterial.fromJson(item))
              .toList();
    });
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      comments = (jsonDecode(prefs.getString('comments') ?? '{}') as Map).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
    });
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('comments', jsonEncode(comments));
  }

  Future<void> _togglePin(StudyMaterial material) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (pinnedResources.any((item) => item.id == material.id)) {
        pinnedResources.removeWhere((item) => item.id == material.id);
      } else {
        pinnedResources.add(material);
      }
    });
    await prefs.setString('pinnedResources',
        jsonEncode(pinnedResources.map((item) => item.toJson()).toList()));
    _fetchMaterials();
  }

  Future<void> _reportMaterial(String materialId) async {
    final reportReasonController = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Report Material',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xFF00246B))),
        content: TextField(
          controller: reportReasonController,
          decoration: const InputDecoration(labelText: 'Reason for Reporting'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              if (reportReasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please provide a reason for reporting.')));
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text('Submit Report', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      debugPrint('Reporting material: $materialId');
      final response = await http.post(
        Uri.parse('http://localhost:5000/report-material'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'materialId': materialId,
          'deviceId': widget.deviceId,
          'reason': reportReasonController.text,
        }),
      );
      debugPrint('Report response: ${response.statusCode}');
      if (response.statusCode == 201) {
        await _fetchMaterials();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Material reported successfully!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to report material: ${jsonDecode(response.body)['message']}')));
        }
      }
    } catch (e) {
      debugPrint('Report error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error reporting material: $e')));
      }
    }
  }

  Future<List<Report>> _fetchReports(String materialId) async {
    debugPrint('Fetching reports for material: $materialId');
    final response = await http.get(
      Uri.parse('http://localhost:5000/reports/$materialId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    debugPrint('Fetch reports response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Report.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load reports: ${response.statusCode}');
    }
  }

  Future<void> _downloadFile(
      String url, String fileName, BuildContext context) async {
    try {
      debugPrint('Downloading file from: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Download response: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch file: HTTP ${response.statusCode}');
      }

      String extension = url.split('.').last.split('?')[0].toLowerCase();
      final sanitizedFileName = '$fileName.$extension';

      if (kIsWeb) {
        final blob = html.Blob([response.bodyBytes]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: blobUrl)
          ..setAttribute('download', sanitizedFileName)
          ..click();
        html.Url.revokeObjectUrl(blobUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Downloading file... Check your browser downloads.')));
        }
      } else {
        PermissionStatus status;
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          status = androidInfo.version.sdkInt >= 33
              ? await Permission.manageExternalStorage.request()
              : await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied.');
          }
        }

        Directory? directory = Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();
        if (Platform.isAndroid && !(await directory.exists())) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Downloads');
            if (!(await directory.exists())) {
              await directory.create(recursive: true);
            }
          }
        } else if (Platform.isIOS) {
          directory = Directory('${directory.path}/Downloads');
          if (!(await directory.exists())) {
            await directory.create(recursive: true);
          }
        }

        if (directory == null) {
          throw Exception('Failed to determine download directory');
        }
        final filePath = '${directory.path}/$sanitizedFileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('File downloaded to: $filePath');

        if (Platform.isIOS && mounted) {
          await Share.shareXFiles([XFile(filePath)],
              text: 'Downloaded file: $sanitizedFileName');
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File downloaded to $filePath')));
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading file: $e')));
      }
    }
  }

  void _showReportsDialog(String materialId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reports for Material',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xFF00246B))),
        content: FutureBuilder<List<Report>>(
          future: _fetchReports(materialId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}',
                  style: GoogleFonts.poppins());
            final reports = snapshot.data!;
            if (reports.isEmpty)
              return Text('No reports for this material.',
                  style: GoogleFonts.poppins());
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ListTile(
                    title: Text(
                        'Reported by: ${report.reportedBy.substring(0, 8)}...',
                        style: GoogleFonts.poppins()),
                    subtitle: Text(
                      'Reason: ${report.reason}\nReported At: ${DateFormat('dd MMM yyyy HH:mm').format(report.reportedAt)}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins()))
        ],
      ),
    );
  }

  void _showCommentsDialog(String materialId) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Comments',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xFF00246B))),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (comments[materialId]?.isNotEmpty ?? false)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments[materialId]!.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(comments[materialId]![index],
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                  ),
                )
              else
                Text('No comments yet.', style: GoogleFonts.poppins()),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: 'Add a comment'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                setState(() {
                  comments[materialId] = comments[materialId] ?? [];
                  comments[materialId]!.add(commentController.text);
                });
                _saveComments();
                Navigator.pop(context);
              }
            },
            child: Text('Submit', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomSearchBar(token: widget.token, deviceId: widget.deviceId),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFilterDepartment,
                    decoration: const InputDecoration(
                        labelText: 'Filter by Department'),
                    items: departments
                        .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept, style: GoogleFonts.poppins())))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilterDepartment = value!;
                        _fetchMaterials();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedYear,
                    decoration:
                        const InputDecoration(labelText: 'Filter by Year'),
                    items: [
                      const DropdownMenuItem(
                          value: null,
                          child: Text('All Years',
                              style: TextStyle(fontFamily: 'Poppins'))),
                      ...years.map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year, style: GoogleFonts.poppins()))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                        _fetchMaterials();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00246B)))
                : _materials.isEmpty
                    ? Center(
                        child: Text('No materials found.',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF00246B))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _materials.length,
                        itemBuilder: (context, index) {
                          final material = _materials[index];
                          final isPinned = pinnedResources
                              .any((item) => item.id == material.id);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ExpansionTile(
                              title: Text(
                                material.subjectName,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color(0xFF00246B)),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Department: ${material.department}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF00246B))),
                                      Text('Year: ${material.year}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF00246B))),
                                      Text('Semester: ${material.semester}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF00246B))),
                                      Text(
                                          'Uploaded At: ${DateFormat('dd MMM yyyy').format(material.uploadedAt)}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF00246B))),
                                      Text(
                                          'Uploaded By: ${material.uploadedBy}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: const Color(0xFF00246B))),
                                      if (material.description.isNotEmpty)
                                        Text(
                                            'Description: ${material.description}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color:
                                                    const Color(0xFF00246B))),
                                      if (material.reportCount > 0)
                                        GestureDetector(
                                          onTap: () =>
                                              _showReportsDialog(material.id),
                                          child: Text(
                                              'Reports: ${material.reportCount}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.red)),
                                        ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility,
                                                color: Color(0xFF00246B)),
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var recent = (jsonDecode(
                                                      prefs.getString(
                                                              'recentlyViewed') ??
                                                          '[]') as List)
                                                  .map((item) =>
                                                      StudyMaterial.fromJson(
                                                          item))
                                                  .toList();
                                              if (!recent.any((item) =>
                                                  item.id == material.id)) {
                                                recent.insert(0, material);
                                                if (recent.length > 10)
                                                  recent =
                                                      recent.sublist(0, 10);
                                                await prefs.setString(
                                                    'recentlyViewed',
                                                    jsonEncode(recent
                                                        .map((item) =>
                                                            item.toJson())
                                                        .toList()));
                                              }
                                              if (mounted) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MaterialPreviewScreen(
                                                      material: material,
                                                      onDownload: _downloadFile,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.download,
                                                color: Color(0xFF00246B)),
                                            onPressed: () => _downloadFile(
                                                material.fileUrl,
                                                material.subjectName,
                                                context),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                                isPinned
                                                    ? Icons.push_pin
                                                    : Icons.push_pin_outlined,
                                                color: isPinned
                                                    ? Colors.red
                                                    : const Color(0xFF00246B)),
                                            onPressed: () =>
                                                _togglePin(material),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.report,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _reportMaterial(material.id),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.comment,
                                                color: Color(0xFF00246B)),
                                            onPressed: () =>
                                                _showCommentsDialog(
                                                    material.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatefulWidget {
  final String token;
  final String deviceId;

  const CustomSearchBar(
      {super.key, required this.token, required this.deviceId});

  @override
  State<CustomSearchBar> createState() => CustomSearchBarState();
}

class CustomSearchBarState extends State<CustomSearchBar> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search resources...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF00246B)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Color(0xFF00246B)),
          onPressed: () => _searchController.clear(),
        ),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          showSearch(
              context: context,
              delegate: CustomSearchDelegate(
                  deviceId: widget.deviceId,
                  token: widget.token,
                  initialQuery: value));
        }
      },
    );
  }
}

class UploadMaterialScreen extends StatefulWidget {
  final String deviceId;
  final String token;

  const UploadMaterialScreen(
      {super.key, required this.deviceId, required this.token});

  @override
  State<UploadMaterialScreen> createState() => UploadMaterialScreenState();
}

class UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _subjectNameController = TextEditingController();
  final _materialTypeController = TextEditingController();
  final _semesterController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedYear;
  String? _selectedFileName;
  Uint8List? _fileBytes;
  bool _isUploading = false;
  String? _errorMessage;
  bool _pinResource = false;

  final List<String> departments = ['CSE', 'ECE', 'Mech', 'Civil', 'EEE'];
  final List<String> years = ['1', '2', '3', '4'];
  final List<String> materialTypes = [
    'Notes',
    'Question Paper',
    'Project Guide'
  ];

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'txt'],
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _fileBytes = result.files.single.bytes;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (_subjectNameController.text.isEmpty ||
        _materialTypeController.text.isEmpty ||
        _semesterController.text.isEmpty ||
        _selectedDepartment == null ||
        _selectedYear == null ||
        _selectedFileName == null ||
        _fileBytes == null) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://localhost:5000/study-materials'));
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.fields['subjectName'] = _subjectNameController.text;
      request.fields['materialType'] = _materialTypeController.text;
      request.fields['semester'] = _semesterController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['department'] = _selectedDepartment!;
      request.fields['year'] = _selectedYear!;
      request.fields['deviceId'] = widget.deviceId;
      final prefs = await SharedPreferences.getInstance();
      request.fields['uploadedBy'] = prefs.getString('userName') ?? 'Unknown';
      request.files.add(http.MultipartFile.fromBytes('file', _fileBytes!,
          filename: _selectedFileName));

      debugPrint(
          'Uploading material to: http://localhost:5000/study-materials');
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      debugPrint('Upload response: ${response.statusCode}');
      if (response.statusCode == 201) {
        final material = StudyMaterial.fromJson(jsonDecode(responseData.body));
        if (_pinResource) {
          final prefs = await SharedPreferences.getInstance();
          var pinned =
              (jsonDecode(prefs.getString('pinnedResources') ?? '[]') as List)
                  .map((item) => StudyMaterial.fromJson(item))
                  .toList();
          pinned.add(material);
          await prefs.setString('pinnedResources',
              jsonEncode(pinned.map((item) => item.toJson()).toList()));
        }
        _subjectNameController.clear();
        _materialTypeController.clear();
        _semesterController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFileName = null;
          _fileBytes = null;
          _selectedDepartment = null;
          _selectedYear = null;
          _pinResource = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material uploaded successfully!')),
          );
        }
      } else {
        setState(() => _errorMessage =
            'Upload failed: ${jsonDecode(responseData.body)['message']}');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      setState(() => _errorMessage = 'Upload failed: $e');
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Add Resource',
              style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00246B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload study materials',
              style: GoogleFonts.poppins(
                  fontSize: 18, color: const Color(0xFF00246B)),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _subjectNameController,
                      decoration:
                          const InputDecoration(labelText: 'Subject Name'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _materialTypeController.text.isNotEmpty
                          ? _materialTypeController.text
                          : null,
                      decoration:
                          const InputDecoration(labelText: 'Material Type'),
                      items: materialTypes
                          .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type, style: GoogleFonts.poppins())))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _materialTypeController.text = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _semesterController,
                      decoration: const InputDecoration(labelText: 'Semester'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration:
                          const InputDecoration(labelText: 'Department'),
                      items: departments
                          .map((dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept, style: GoogleFonts.poppins())))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedYear,
                      decoration: const InputDecoration(labelText: 'Year'),
                      items: years
                          .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year, style: GoogleFonts.poppins())))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text('Attach File',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: const Color(0xFF00246B))),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file),
                          label:
                              Text('Upload File', style: GoogleFonts.poppins()),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCADCFC)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedFileName ?? 'No file selected',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Pin this resource',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF00246B))),
                      value: _pinResource,
                      onChanged: (value) =>
                          setState(() => _pinResource = value!),
                      activeColor: const Color(0xFF00246B),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : AnimatedScaleButton(
                              onPressed: _uploadMaterial,
                              child: Text('Submit',
                                  style: GoogleFonts.poppins(fontSize: 18)),
                            ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscussionForumPagePlaceholder extends StatelessWidget {
  const DiscussionForumPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Discussion Forum - To be implemented',
        style:
            GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF00246B)),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String deviceId;
  final String token;
  final String userName;

  const ProfilePage(
      {super.key,
      required this.deviceId,
      required this.token,
      required this.userName});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  List<StudyMaterial> _materials = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchUserMaterials();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? widget.userName;
      _emailController.text = prefs.getString('userEmail') ?? '';
      _bioController.text = prefs.getString('userBio') ?? '';
    });
  }

  Future<void> _fetchUserMaterials() async {
    try {
      debugPrint(
          'Fetching user materials from: http://localhost:5000/user-materials?deviceId=${widget.deviceId}');
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/user-materials?deviceId=${widget.deviceId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      debugPrint('Fetch user materials response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _materials =
              data.map((item) => StudyMaterial.fromJson(item)).toList();
        });
      } else {
        throw Exception(
            'Failed to load user materials: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user materials: $e');
    }
  }

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userBio', _bioController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match!')));
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:5000/api/users/change-password'), // Assuming this endpoint exists
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully!')));
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to change password: ${jsonDecode(response.body)['message']}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error changing password: $e')));
      }
    }
  }

  Future<void> _deleteMaterial(String materialId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/study-materials/$materialId'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _materials.removeWhere((material) => material.id == materialId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Material deleted successfully!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Failed to delete material: ${response.statusCode}')));
        }
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting material: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFCADCFC),
              child: Text(widget.userName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 48, color: const Color(0xFF00246B))),
            ),
            const SizedBox(height: 16),
            Text(
              'Profile',
              style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00246B)),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    AnimatedScaleButton(
                      onPressed: _updateProfile,
                      child: Text('Update Bio',
                          style: GoogleFonts.poppins(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Change Password',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00246B)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _currentPasswordController,
                      decoration:
                          const InputDecoration(labelText: 'Current Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      decoration:
                          const InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                          labelText: 'Confirm New Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    AnimatedScaleButton(
                      onPressed: _changePassword,
                      child: Text('Change Password',
                          style: GoogleFonts.poppins(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Uploaded Materials',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00246B)),
            ),
            const SizedBox(height: 8),
            _materials.isEmpty
                ? Text('No materials uploaded yet',
                    style: GoogleFonts.poppins(color: const Color(0xFF00246B)))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _materials.length,
                    itemBuilder: (context, index) {
                      final material = _materials[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(material.subjectName,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF00246B))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMaterial(material.id),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class StudyMaterial {
  final String id;
  final String subjectName;
  final String materialType;
  final String semester;
  final String description;
  final String department;
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int reportCount;
  final String year;

  StudyMaterial({
    required this.id,
    required this.subjectName,
    required this.materialType,
    required this.semester,
    required this.description,
    required this.department,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.reportCount,
    required this.year,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['_id'],
      subjectName: json['subjectName'],
      materialType: json['materialType'],
      semester: json['semester'],
      description: json['description'],
      department: json['department'],
      fileUrl: json['fileUrl'],
      uploadedBy: json['uploadedBy'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      reportCount: json['reportCount'] ?? 0,
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'subjectName': subjectName,
      'materialType': materialType,
      'semester': semester,
      'description': description,
      'department': department,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt.toIso8601String(),
      'reportCount': reportCount,
      'year': year,
    };
  }
}

class Report {
  final String id;
  final String materialId;
  final String reportedBy;
  final String reason;
  final DateTime reportedAt;

  Report({
    required this.id,
    required this.materialId,
    required this.reportedBy,
    required this.reason,
    required this.reportedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      materialId: json['materialId'],
      reportedBy: json['reportedBy'],
      reason: json['reason'],
      reportedAt: DateTime.parse(json['reportedAt']),
    );
  }
}

class MaterialPreviewScreen extends StatefulWidget {
  final StudyMaterial material;
  final Future<void> Function(String, String, BuildContext) onDownload;

  const MaterialPreviewScreen(
      {super.key, required this.material, required this.onDownload});

  @override
  State<MaterialPreviewScreen> createState() => MaterialPreviewScreenState();
}

class MaterialPreviewScreenState extends State<MaterialPreviewScreen> {
  bool _isLoading = true;
  String? _filePath;
  String? _errorMessage;
  Uint8List? _fileBytes;

  @override
  void initState() {
    super.initState();
    _loadFileForPreview();
  }

  Future<void> _loadFileForPreview() async {
    try {
      debugPrint('Starting preview for URL: ${widget.material.fileUrl}');
      final response = await http.get(Uri.parse(widget.material.fileUrl));
      debugPrint('Preview HTTP Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to load file: HTTP ${response.statusCode}');
      }

      final extension =
          widget.material.fileUrl.split('.').last.split('?')[0].toLowerCase();
      debugPrint('File extension: $extension');
      debugPrint('File size: ${response.bodyBytes.length} bytes');

      if (kIsWeb) {
        if (extension == 'pdf') {
          registerViewFactory(
              'pdf-preview-${widget.material.id}', widget.material.fileUrl);
        }
        _fileBytes = response.bodyBytes;
        setState(() => _isLoading = false);
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFilePath =
            '${tempDir.path}/${widget.material.subjectName}.$extension';
        final file = File(tempFilePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Mobile: File saved to $tempFilePath');
        setState(() {
          _filePath = tempFilePath;
          _fileBytes = response.bodyBytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Preview error: $e');
      setState(() {
        _errorMessage = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.subjectName, style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => widget.onDownload(
                widget.material.fileUrl, widget.material.subjectName, context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00246B)))
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style:
                          GoogleFonts.poppins(color: Colors.red, fontSize: 18)))
              : _buildPreview(),
    );
  }

  Widget _buildPreview() {
    final extension =
        widget.material.fileUrl.split('.').last.split('?')[0].toLowerCase();
    debugPrint('Building preview for extension: $extension');

    if (kIsWeb) {
      switch (extension) {
        case 'pdf':
          debugPrint('Rendering PDF preview for web with iframe');
          return SizedBox.expand(
            child: HtmlElementView(
              viewType: 'pdf-preview-${widget.material.id}',
            ),
          );
        case 'jpg':
        case 'png':
          debugPrint('Rendering image preview for web');
          if (_fileBytes == null) {
            return Center(
                child: Text('Image data not loaded',
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return Image.memory(_fileBytes!, fit: BoxFit.contain);
        case 'txt':
          debugPrint('Rendering text preview for web');
          if (_fileBytes == null) {
            return Center(
                child: Text('Text data not loaded',
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(utf8.decode(_fileBytes!),
                style: GoogleFonts.poppins(color: const Color(0xFF00246B))),
          );
        default:
          debugPrint('Unsupported file type for web: $extension');
          return Center(
            child: ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(widget.material.fileUrl)),
              child: Text('Open in Browser', style: GoogleFonts.poppins()),
            ),
          );
      }
    } else {
      switch (extension) {
        case 'pdf':
          debugPrint('Rendering PDF preview for mobile: $_filePath');
          if (_filePath == null) {
            return Center(
                child: Text('PDF file not loaded',
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return PDFView(
              filePath: _filePath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true);
        case 'jpg':
        case 'png':
          debugPrint('Rendering image preview for mobile: $_filePath');
          if (_filePath == null) {
            return Center(
                child: Text('Image file not loaded',
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return Image.file(File(_filePath!), fit: BoxFit.contain);
        case 'txt':
          debugPrint('Rendering text preview for mobile');
          if (_fileBytes == null) {
            return Center(
                child: Text('Text data not loaded',
                    style:
                        GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(utf8.decode(_fileBytes!),
                style: GoogleFonts.poppins(color: const Color(0xFF00246B))),
          );
        default:
          debugPrint('Unsupported file type for mobile: $extension');
          return Center(
            child: ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(widget.material.fileUrl)),
              child: Text('Open in Browser', style: GoogleFonts.poppins()),
            ),
          );
      }
    }
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final String deviceId;
  final String token;
  final String initialQuery;

  CustomSearchDelegate(
      {required this.deviceId, required this.token, required this.initialQuery})
      : super(searchFieldLabel: 'Search resources...');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  Future<List<StudyMaterial>> _searchMaterials() async {
    debugPrint('Searching materials with query: $query');
    final response = await http.get(
      Uri.parse(
          'http://localhost:5000/study-materials/search?query=${query.isEmpty ? initialQuery : query}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('Search response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => StudyMaterial.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search materials: ${response.statusCode}');
    }
  }

  Future<void> _downloadFile(
      String url, String fileName, BuildContext context) async {
    try {
      debugPrint('Downloading file from: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('Download response: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch file: HTTP ${response.statusCode}');
      }

      String extension = url.split('.').last.split('?')[0].toLowerCase();
      final sanitizedFileName = '$fileName.$extension';

      if (kIsWeb) {
        final blob = html.Blob([response.bodyBytes]);
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: blobUrl)
          ..setAttribute('download', sanitizedFileName)
          ..click();
        html.Url.revokeObjectUrl(blobUrl);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Downloading file... Check your browser downloads.')));
      } else {
        PermissionStatus status;
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          status = androidInfo.version.sdkInt >= 33
              ? await Permission.manageExternalStorage.request()
              : await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied.');
          }
        }

        Directory? directory = Platform.isAndroid
            ? Directory('/storage/emulated/0/Download')
            : await getApplicationDocumentsDirectory();
        if (Platform.isAndroid && !(await directory.exists())) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Downloads');
            if (!(await directory.exists())) {
              await directory.create(recursive: true);
            }
          }
        } else if (Platform.isIOS) {
          directory = Directory('${directory.path}/Downloads');
          if (!(await directory.exists())) {
            await directory.create(recursive: true);
          }
        }

        if (directory == null) {
          throw Exception('Failed to determine download directory');
        }
        final filePath = '${directory.path}/$sanitizedFileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('File downloaded to: $filePath');

        if (Platform.isIOS) {
          await Share.shareXFiles([XFile(filePath)],
              text: 'Downloaded file: $sanitizedFileName');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File downloaded to $filePath')));
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error downloading file: $e')));
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<StudyMaterial>>(
      future: _searchMaterials(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00246B)));
        if (snapshot.hasError)
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: const Color(0xFF00246B))));
        final results = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final material = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(material.subjectName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF00246B))),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Department: ${material.department}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: const Color(0xFF00246B))),
                        Text('Year: ${material.year}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: const Color(0xFF00246B))),
                        Text('Semester: ${material.semester}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: const Color(0xFF00246B))),
                        Text(
                            'Uploaded At: ${DateFormat('dd MMM yyyy').format(material.uploadedAt)}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: const Color(0xFF00246B))),
                        Text('Uploaded By: ${material.uploadedBy}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: const Color(0xFF00246B))),
                        if (material.description.isNotEmpty)
                          Text('Description: ${material.description}',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF00246B))),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Color(0xFF00246B)),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                var recent = (jsonDecode(
                                        prefs.getString('recentlyViewed') ??
                                            '[]') as List)
                                    .map((item) => StudyMaterial.fromJson(item))
                                    .toList();
                                if (!recent
                                    .any((item) => item.id == material.id)) {
                                  recent.insert(0, material);
                                  if (recent.length > 10)
                                    recent = recent.sublist(0, 10);
                                  await prefs.setString(
                                      'recentlyViewed',
                                      jsonEncode(recent
                                          .map((item) => item.toJson())
                                          .toList()));
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MaterialPreviewScreen(
                                      material: material,
                                      onDownload: _downloadFile,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.download,
                                  color: Color(0xFF00246B)),
                              onPressed: () => _downloadFile(material.fileUrl,
                                  material.subjectName, context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AnimatedScaleButton(
      {super.key, required this.onPressed, required this.child});

  @override
  State<AnimatedScaleButton> createState() => AnimatedScaleButtonState();
}

class AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}
