import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'resource_list_screen.dart';
import '../models/study_material.dart';
import '../widgets/exam_date_dialog.dart';
import '../widgets/study_plan_dialog.dart';
import '../utils/notifications.dart';

class HomeDashboard extends StatefulWidget {
  final String deviceId;
  final String token;
  final String userName;

  const HomeDashboard({
    super.key,
    required this.deviceId,
    required this.token,
    required this.userName,
  });

  @override
  State<HomeDashboard> createState() => HomeDashboardState();
}

class HomeDashboardState extends State<HomeDashboard> {
  List<StudyMaterial> recentlyViewed = [];
  List<StudyMaterial> pinnedResources = [];
  List<Map<String, dynamic>> examDates = [];
  List<Map<String, dynamic>> studyPlans = [];

  // JDoodle IDE related fields
  final TextEditingController _codeController = TextEditingController();
  String _output = '';
  bool _isLoading = false;
  String _selectedLanguage = 'C'; // Default language
  final String clientId = 'd16f9711413d99c163af11af6a42ae3b';
  final String clientSecret =
      '5d51ad2c36d5c55da8d6b4842d6a068e3b22ec11cf48b457c3053916f2bb79dc';
  final Map<String, Map<String, String>> _languageOptions = {
    'C': {'code': 'c', 'versionIndex': '4'},
    'C++': {'code': 'cpp', 'versionIndex': '4'},
    'Java': {'code': 'java', 'versionIndex': '4'},
    'Python': {'code': 'python3', 'versionIndex': '4'},
  };

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
      studyPlans = (jsonDecode(prefs.getString('studyPlans') ?? '[]') as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    });
    await _fetchExamDates(prefs);
    await _scheduleNotifications();
  }

  Future<void> _fetchExamDates(SharedPreferences prefs) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/exam-dates'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      debugPrint(
          'Fetch exam dates response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          examDates = data
              .map((item) => {
                    'name': item['name'],
                    'date': item['date'],
                    'uploadedBy': item['uploadedBy'],
                    'uploadedAt': item['uploadedAt'],
                  })
              .toList();
        });
        await prefs.setString('examDates', jsonEncode(examDates));
      } else {
        debugPrint(
            'Failed to fetch exam dates: ${response.statusCode} - ${response.body}');
        setState(() {
          examDates = (jsonDecode(prefs.getString('examDates') ?? '[]') as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching exam dates: $e');
      setState(() {
        examDates = (jsonDecode(prefs.getString('examDates') ?? '[]') as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      });
    }
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

  Future<void> _executeCode() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    final String proxyUrl = 'http://localhost:2001/execute';
    final String script = _codeController.text;
    final String language = _languageOptions[_selectedLanguage]!['code']!;
    final String versionIndex =
        _languageOptions[_selectedLanguage]!['versionIndex']!;

    final Map<String, String> payload = {
      'clientId': clientId,
      'clientSecret': clientSecret,
      'script': script,
      'language': language,
      'versionIndex': versionIndex,
    };

    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _output = result['output'] ?? 'No output received';
        });
      } else {
        setState(() {
          _output = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Exception occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          deviceId: widget.deviceId,
        ),
      ),
    );
  }

  void _showJDoodleIDE() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JDoodle IDE'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                      _codeController.clear();
                      _output = '';
                    });
                  },
                  items: _languageOptions.keys
                      .map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type your code here...',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _executeCode,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Run Code'),
                ),
                const SizedBox(height: 10),
                const Text('Output:'),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(_output.isEmpty ? 'No output yet' : _output),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Function to launch the KEC map URL
  Future<void> _launchKECMap() async {
    const url = 'https://naveenkumarr21.github.io/kec_study_app/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the map')),
      );
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
                                    color: const Color(0xFF00246B),
                                    fontSize: 12)),
                          ),
                        ),
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => const ExamDateDialog());
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
                                    color: const Color(0xFF00246B),
                                    fontSize: 12)),
                          ),
                        ),
                  onTap: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => const StudyPlanDialog());
                    if (result != null) {
                      setState(() => studyPlans.add(result));
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'studyPlans', jsonEncode(studyPlans));
                      await _scheduleNotifications();
                    }
                  },
                ),
                _buildCard(
                  title: 'Coding Platform',
                  icon: Icons.code,
                  content: Center(
                    child: Text(
                      'Code and Run',
                      style:
                          GoogleFonts.poppins(color: const Color(0xFF00246B)),
                    ),
                  ),
                  onTap: _showJDoodleIDE,
                ),
              ],
            ),
            const SizedBox(height: 20), // Add some spacing
            ElevatedButton.icon(
              onPressed: _launchKECMap,
              icon: const Icon(Icons.map, color: Colors.white),
              label: Text(
                'Interactive KEC Map',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00246B), // Match your theme
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
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
                    child: Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00246B)),
                        overflow: TextOverflow.ellipsis),
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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
