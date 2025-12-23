import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

/* ================= 로그인 페이지 ================= */

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        throw Exception("Web으로 실행하세요");
      }

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TodayEventPage()),
      );
    } catch (e) {
      debugPrint("로그인 실패: $e");
      // ignore: use_build_context_synchronously
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
          onPressed: () => loginWithGoogle(context),
          child: const Text("Google 로그인 후 오늘 일정 보기"),
        ),
      ),
    );
  }
}

/* ================= 오늘 일정 페이지 (STEP 5) ================= */

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

  // --------------------
  // STEP 5: 오늘 일정 조회
  // --------------------
  Future<void> fetchTodayEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          todayEvents = [];
        });
        return;
      }

      final today = DateTime.now();
      final todayString = today.toIso8601String().substring(0, 10);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .get();

      final events = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // 🔥 오늘 날짜 필터링
      final filtered = events.where((e) =>
        e['date'] == todayString
      ).toList();

      setState(() {
        todayEvents = filtered;
        loading = false;
      });

    } catch (e) {
      debugPrint("오늘 일정 불러오기 실패: $e");
      setState(() {
        loading = false;
        todayEvents = [];
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "(로그인 없음)";

    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘 일정"),
        actions: [
          TextButton(
            onPressed: logout,
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text("현재 UID: $uid"),
                ),
                const Divider(),
                Expanded(
                  child: todayEvents.isEmpty
                      ? const Center(child: Text("오늘 일정이 없습니다"))
                      : ListView.builder(
                          itemCount: todayEvents.length,
                          itemBuilder: (context, index) {
                            final e = todayEvents[index];
                            return ListTile(
                              title: Text(e['title'] ?? ''),
                              subtitle: Text(
                                "${e['startTime']} ~ ${e['endTime']}",
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
