import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

const Color pointColor = Color(0xFF4A6FA5); // 청회색 포인트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

/* ================= App Root ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: pointColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

/* ================= 로그인 페이지 ================= */

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      if (!kIsWeb) {
        throw Exception("Web으로 실행하세요");
      }

      final provider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(provider);

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TodayEventPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login (Google)")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: pointColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => loginWithGoogle(context),
          child: const Text("Google 로그인"),
        ),
      ),
    );
  }
}

/* ================= 오늘 일정 페이지 ================= */

class TodayEventPage extends StatefulWidget {
  const TodayEventPage({super.key});

  @override
  State<TodayEventPage> createState() => _TodayEventPageState();
}

class _TodayEventPageState extends State<TodayEventPage> {
  bool loading = true;
  List<Map<String, dynamic>> todayEvents = [];

  @override
  void initState() {
    super.initState();
    fetchTodayEvents();
  }

  /* ================= 오늘 일정 조회 ================= */

  Future<void> fetchTodayEvents() async {
    try {
      print("🔥 fetchTodayEvents 시작");
      final user = FirebaseAuth.instance.currentUser;

      print("🔥 currentUser = ${user?.uid}");

      if (user == null) {
        setState(() {
          loading = false;
        });
        return;
      }

      final todayString =
          DateTime.now().toIso8601String().substring(0, 10);

      print("🔥 todayString = $todayString");

      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('uid', isEqualTo: user.uid)
          .where('date', isEqualTo: todayString)
          .get(); // ❗ orderBy 제거 (무한 로딩 방지)

      print("🔥 가져온 문서 수 = ${snapshot.docs.length}");

      final events = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      setState(() {
        todayEvents = events;
      });
    } catch (e) {
      debugPrint("🔥 fetchTodayEvents error: $e");
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /* ================= 일정 추가 ================= */

  Future<void> addEventWithDatePicker() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
    );

    if (pickedDate == null) return;

    final dateString =
        pickedDate.toIso8601String().substring(0, 10);

    await FirebaseFirestore.instance.collection('schedules').add({
      'uid': user.uid,
      'title': '모바일에서 추가한 일정',
      'date': dateString,
      'startTime': '14:00',
      'endTime': '15:00',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      loading = true;
    });
    fetchTodayEvents();
  }

  /* ================= 로그아웃 ================= */

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "(없음)";

    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘 일정"),
        actions: [
          TextButton(
            onPressed: logout,
            child: const Text(
              "Logout",
              style: TextStyle(color: pointColor),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "현재 UID: $uid",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: todayEvents.isEmpty
                      ? const Center(child: Text("오늘 일정이 없습니다"))
                      : ListView.builder(
                          itemCount: todayEvents.length,
                          itemBuilder: (context, index) {
                            final e = todayEvents[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(e['title']),
                                subtitle: Text(
                                  "${e['startTime']} ~ ${e['endTime']}",
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: pointColor,
        onPressed: addEventWithDatePicker,
        icon: const Icon(Icons.date_range),
        label: const Text("날짜 선택"),
      ),
    );
  }
}
