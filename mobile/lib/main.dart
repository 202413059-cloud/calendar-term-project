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
      // ✅ Flutter Web: Google Popup 로그인
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final result =
            await FirebaseAuth.instance.signInWithPopup(provider);

        debugPrint("구글 로그인 성공 uid=${result.user?.uid}");
      } else {
        throw Exception("지금은 Web으로 실행하세요.");
      }

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EventListPage()),
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
          child: const Text("Google 로그인 후 일정 보기"),
        ),
      ),
    );
  }
}

/* ================= 일정 목록 페이지 ================= */

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  bool loading = true;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents(); // 페이지 진입 시 자동 조회
  }

  // --------------------
  // STEP 9: Read
  // --------------------
  Future<void> fetchEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          events = [];
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .orderBy('createdAt', descending: true)
          .get();

      final data = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        events = data;
        loading = false;
      });

      debugPrint("불러온 일정: $data");
    } catch (e) {
      debugPrint("일정 불러오기 실패: $e");
      setState(() {
        loading = false;
        events = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("일정 불러오기 실패: $e")),
        );
      }
    }
  }

  // --------------------
  // ✅ STEP 10: Create (Mobile)
  // --------------------
  Future<void> addEventFromMobile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("로그인 안 됨");
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .add({
      'title': '모바일 일정',
      'date': '2025-12-26',
      'startTime': '15:00',
      'endTime': '16:00',
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint("모바일 일정 추가 완료");

    // 추가 후 즉시 다시 조회
    fetchEvents();
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
        title: const Text("Mobile(Web) Event List"),
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
                  child: events.isEmpty
                      ? const Center(child: Text("일정이 없습니다"))
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final e = events[index];
                            return ListTile(
                              title: Text(e['title'] ?? ''),
                              subtitle: Text(
                                "${e['date']} ${e['startTime']} ~ ${e['endTime']}",
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

      // 🔥 STEP 10 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addEventFromMobile,
        icon: const Icon(Icons.add),
        label: const Text("모바일 일정 추가"),
      ),
    );
  }
}
