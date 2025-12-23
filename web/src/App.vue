<script setup>
import { ref } from "vue";
import { auth, db } from "./firebase";

// Auth
import { GoogleAuthProvider, signInWithPopup, signOut } from "firebase/auth";

// Firestore
import {
  collection,
  addDoc,
  serverTimestamp,
  getDocs,
  query,
  orderBy,
} from "firebase/firestore";

const uid = ref("");
const events = ref([]);
const filteredEvents = ref([]);

// 로그인
const login = async () => {
  const provider = new GoogleAuthProvider();
  const result = await signInWithPopup(auth, provider);
  uid.value = result.user.uid;
  console.log("login uid:", uid.value);
};

// 로그아웃
const logout = async () => {
  await signOut(auth);
  uid.value = "";
  events.value = [];
  filteredEvents.value = [];
};

// STEP 3: Create
const addEvent = async () => {
  const user = auth.currentUser;
  if (!user) {
    alert("먼저 로그인하세요");
    return;
  }

  await addDoc(collection(db, "users", user.uid, "events"), {
    title: "테스트 일정",
    date: "2025-12-26",
    startTime: "10:00",
    endTime: "12:00",
    createdAt: serverTimestamp(),
  });

  alert("일정 추가 완료!");
};

// STEP 4: Read
const fetchEvents = async () => {
  const user = auth.currentUser;
  if (!user) return;

  const q = query(
    collection(db, "users", user.uid, "events"),
    orderBy("createdAt", "desc")
  );

  const snapshot = await getDocs(q);
  events.value = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  console.log("불러온 일정 목록:", events.value);
};

// STEP 5: 특정 날짜 필터링
const getEventsByDate = (date) => {
  filteredEvents.value = events.value.filter(
    e => e.date === date
  );
};
</script>

<template>
  <div style="padding: 24px">
    <h2>Web Firebase Test</h2>

    <div style="display:flex; gap:12px; margin-bottom:16px;">
      <button @click="login">Google Login</button>
      <button @click="logout">Logout</button>
    </div>

    <p v-if="uid">현재 로그인 UID: {{ uid }}</p>
    <p v-else>로그인 안됨</p>

    <hr style="margin:16px 0;" />

    <div style="display:flex; gap:12px; margin-bottom:16px;">
      <button @click="addEvent">일정 추가(Create)</button>
      <button @click="fetchEvents">일정 목록 조회(Read)</button>
      <button @click="getEventsByDate('2025-12-26')">
        2025-12-26 일정만 보기
      </button>
    </div>

    <ul>
      <li v-for="event in filteredEvents" :key="event.id">
        {{ event.date }} | {{ event.title }}
        ({{ event.startTime }} ~ {{ event.endTime }})
      </li>
    </ul>
  </div>
</template>
