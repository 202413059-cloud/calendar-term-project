import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("로그인이 필요합니다"));
    }

    final today = DateTime.now();
    final todayString = today.toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text("오늘 일정"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔥 Firestore → Map 리스트
          final events = snapshot.data!.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            };
          }).toList();

          // 🔥 오늘 일정만 필터링
          final todayEvents = events.where((e) =>
            e['date'] == todayString
          ).toList();

          if (todayEvents.isEmpty) {
            return const Center(
              child: Text("오늘 일정이 없습니다"),
            );
          }

          // 🔥 리스트 UI
          return ListView.builder(
            itemCount: todayEvents.length,
            itemBuilder: (context, index) {
              final event = todayEvents[index];
              return ListTile(
                title: Text(event['title']),
                subtitle: Text(
                  "${event['startTime']} ~ ${event['endTime']}",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
