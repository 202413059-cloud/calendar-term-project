<script setup>
import { ref, computed } from "vue";
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
  doc,
  updateDoc,
  deleteDoc,
} from "firebase/firestore";

/* =========================
   🔐 Auth 상태
========================= */
const uid = ref("");
const events = ref([]);
const filteredEvents = ref([]);

/* =========================
   🔐 로그인 / 로그아웃
========================= */
const login = async () => {
  const provider = new GoogleAuthProvider();
  const result = await signInWithPopup(auth, provider);
  uid.value = result.user.uid;
};

const logout = async () => {
  await signOut(auth);
  uid.value = "";
  events.value = [];
  filteredEvents.value = [];
};

/* =========================
   📌 STEP 3: Create
========================= */
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

/* =========================
   📌 STEP 4: Read
========================= */
const fetchEvents = async () => {
  const user = auth.currentUser;
  if (!user) return;

  const q = query(
    collection(db, "users", user.uid, "events"),
    orderBy("createdAt", "desc")
  );

  const snapshot = await getDocs(q);
  events.value = snapshot.docs.map((docSnap) => ({
    id: docSnap.id,
    ...docSnap.data(),
  }));

  filteredEvents.value = events.value;
};

/* =========================
   📌 STEP 5: 날짜 필터링
========================= */
const getEventsByDate = (date) => {
  filteredEvents.value = events.value.filter(
    (e) => e.date === date
  );
};

/* =========================
   📌 STEP 6: Update
========================= */
const updateEvent = async (eventId) => {
  const user = auth.currentUser;
  if (!user) {
    alert("먼저 로그인하세요");
    return;
  }

  await updateDoc(
    doc(db, "users", user.uid, "events", eventId),
    { title: "수정된 일정" }
  );

  alert("일정 수정 완료!");
};

/* =========================
   📌 STEP 7: Delete
========================= */
const deleteEvent = async (eventId) => {
  const user = auth.currentUser;
  if (!user) {
    alert("먼저 로그인하세요");
    return;
  }

  await deleteDoc(
    doc(db, "users", user.uid, "events", eventId)
  );

  events.value = events.value.filter((e) => e.id !== eventId);
  filteredEvents.value = filteredEvents.value.filter(
    (e) => e.id !== eventId
  );

  alert("일정 삭제 완료!");
};

/* =========================
   📅 STEP 1: 캘린더 UI
========================= */
const currentDate = ref(new Date());

const year = () => currentDate.value.getFullYear();
const month = () => currentDate.value.getMonth(); // 0~11

const getDaysInMonth = (year, month) => {
  const days = [];
  const lastDay = new Date(year, month + 1, 0).getDate();

  for (let i = 1; i <= lastDay; i++) {
    days.push(new Date(year, month, i));
  }
  return days;
};

const days = computed(() => {
  return getDaysInMonth(year(), month());
});

/* =========================
   📅 STEP 2: 요일 색상
========================= */
const getDayClass = (date) => {
  const day = date.getDay(); // 0:일, 6:토
  if (day === 0) return "sunday";
  if (day === 6) return "saturday";
  return "weekday";
};
</script>

<template>
  <div style="padding:24px">
    <h2>Web Firebase Test</h2>

    <!-- 로그인 -->
    <div style="display:flex; gap:12px; margin-bottom:16px;">
      <button @click="login">Google Login</button>
      <button @click="logout">Logout</button>
    </div>

    <p v-if="uid">현재 로그인 UID: {{ uid }}</p>
    <p v-else>로그인 안됨</p>

    <hr style="margin:24px 0;" />

    <!-- CRUD 버튼 -->
    <div style="display:flex; gap:12px; margin-bottom:16px;">
      <button @click="addEvent">일정 추가(Create)</button>
      <button @click="fetchEvents">일정 목록 조회(Read)</button>
      <button @click="getEventsByDate('2025-12-26')">
        2025-12-26 일정만 보기
      </button>
    </div>

    <!-- 📅 캘린더 -->
    <h3>{{ year() }}년 {{ month() + 1 }}월</h3>

    <div class="calendar">
      <div
        v-for="day in days"
        :key="day.toISOString()"
        class="day"
        :class="getDayClass(day)"
      >
        {{ day.getDate() }}
      </div>
    </div>

    <hr style="margin:24px 0;" />

    <!-- 일정 리스트 -->
    <ul>
      <li v-for="event in filteredEvents" :key="event.id">
        {{ event.date }} | {{ event.title }}
        ({{ event.startTime }} ~ {{ event.endTime }})

        <button
          style="margin-left:10px"
          @click="updateEvent(event.id)"
        >
          수정
        </button>

        <button
          style="margin-left:6px; color:red"
          @click="deleteEvent(event.id)"
        >
          삭제
        </button>
      </li>
    </ul>
  </div>
</template>

<style>
.calendar {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 8px;
  margin-bottom: 24px;
}

.day {
  padding: 12px;
  border: 1px solid #ddd;
  text-align: center;
}

/* STEP 2: 요일 색상 */
.weekday {
  color: #000;
}

.saturday {
  color: #2f6fff;
}

.sunday {
  color: #ff4d4f;
}
</style>
