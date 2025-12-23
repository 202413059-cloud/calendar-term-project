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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> signInWithGoogle() async {
    final userCredential =
        await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );

    final user = userCredential.user;
    print(user?.uid);
  }

  Future<void> addTestEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('로그인 필요');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .add({
      'title': '테스트 일정',
      'date': '2025-12-26',
      'startTime': '10:00',
      'endTime': '11:00',
      'createdAt': Timestamp.now(),
    });

    print('이벤트 저장 완료');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Firebase Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: const Text("Google Login"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTestEvent,
              child: const Text("이벤트 저장 테스트"),
            ),
          ],
        ),
      ),
    );
  }
}
