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

/* ---------------- 로그인 페이지 ---------------- */

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> login() async {
    await FirebaseAuth.instance.signInAnonymously();
    debugPrint("로그인 완료");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await login();
            // 로그인 후 이벤트 페이지로 이동
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EventListPage(),
              ),
            );
          },
          child: const Text("로그인 후 일정 보기"),
        ),
      ),
    );
  }
}

/* ---------------- 일정 목록 페이지 ---------------- */

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];

  Future<void> fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("로그인 안 됨");
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      events = data;
    });

    debugPrint("불러온 일정: $data");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mobile Event List")),
      body: Column(
        children: [
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: fetchEvents,
            child: const Text("일정 목록 불러오기"),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
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
    );
  }
}
