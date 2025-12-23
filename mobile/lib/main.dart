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
      home: EventListPage(),
    );
  }
}

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Map<String, dynamic>> events = [];

  // STEP 9: Firestore Read
  Future<void> fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("로그인 안 됨");
      return;
    }

    final uid = user.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .get();

    final data = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      events = data;
    });

    // 콘솔 확인용
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
