<script setup>
import { ref, computed, watch } from "vue";
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
   🎨 디자인 상수
========================= */
const POINT_COLOR = "#4a6fa5";

/* =========================
   🔧 날짜 유틸 (🔥 핵심)
========================= */
const formatDate = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`; // YYYY-MM-DD
};

/* =========================
   🔐 Auth 상태
========================= */
const uid = ref("");
const events = ref([]);
const filteredEvents = ref([]);
const selectedDate = ref(null);

/* =========================
   🔐 로그인 / 로그아웃
========================= */
const login = async () => {
  const provider = new GoogleAuthProvider();
  const result = await signInWithPopup(auth, provider);
  uid.value = result.user.uid;
  await fetchEvents();
};

const logout = async () => {
  await signOut(auth);
  uid.value = "";
  events.value = [];
  filteredEvents.value = [];
  selectedDate.value = null;
};

/* =========================
   📌 Create (🔥 schedules에 저장)
========================= */
const addEvent = async () => {
  const user = auth.currentUser;
  if (!user) return;

  const today = formatDate(new Date());

  await addDoc(collection(db, "schedules"), {
    uid: user.uid,
    title: "웹에서 추가한 일정",
    date: today,
    startTime: "10:00",
    endTime: "12:00",
    createdAt: serverTimestamp(),
  });

  await fetchEvents();
};

/* =========================
   📌 Read (🔥 schedules에서 조회)
========================= */
const fetchEvents = async () => {
  const user = auth.currentUser;
  if (!user) return;

  const q = query(
    collection(db, "schedules"),
    orderBy("createdAt", "desc")
  );

  const snapshot = await getDocs(q);

  // 🔥 uid 기준 필터링
  events.value = snapshot.docs
    .map((docSnap) => ({
      id: docSnap.id,
      ...docSnap.data(),
    }))
    .filter((e) => e.uid === user.uid);

  filteredEvents.value = events.value;
};

/* =========================
   📌 날짜 필터링
========================= */
const getEventsByDate = (ymd) => {
  filteredEvents.value = events.value.filter(
    (e) => e.date === ymd
  );
};

/* =========================
   📌 Update
========================= */
const updateEvent = async (eventId) => {
  await updateDoc(
    doc(db, "schedules", eventId),
    { title: "수정된 일정" }
  );
  await fetchEvents();
};

/* =========================
   📌 Delete
========================= */
const deleteEvent = async (eventId) => {
  await deleteDoc(doc(db, "schedules", eventId));
  events.value = events.value.filter((e) => e.id !== eventId);
  filteredEvents.value = filteredEvents.value.filter(
    (e) => e.id !== eventId
  );
};

/* =========================
   📅 캘린더 UI
========================= */
const currentDate = ref(new Date());

const year = () => currentDate.value.getFullYear();
const month = () => currentDate.value.getMonth();

const getDaysInMonth = (year, month) => {
  const days = [];
  const lastDay = new Date(year, month + 1, 0).getDate();
  for (let i = 1; i <= lastDay; i++) {
    days.push(new Date(year, month, i));
  }
  return days;
};

const days = computed(() =>
  getDaysInMonth(year(), month())
);

/* =========================
   📅 요일 색상
========================= */
const getDayClass = (date) => {
  const day = date.getDay();
  if (day === 0) return "sunday";
  if (day === 6) return "saturday";
  return "weekday";
};

/* =========================
   📅 월 이동
========================= */
const prevMonth = () => {
  currentDate.value = new Date(year(), month() - 1, 1);
};

const nextMonth = () => {
  currentDate.value = new Date(year(), month() + 1, 1);
};

/* =========================
   📅 날짜 선택
========================= */
const selectDate = (date) => {
  const ymd = formatDate(date);
  selectedDate.value = ymd;
  getEventsByDate(ymd);
};

watch(currentDate, () => {
  selectedDate.value = null;
  filteredEvents.value = events.value;
});
</script>

<template>
  <div class="page">
    <h2>Web Calendar</h2>

    <div class="row">
      <button @click="login">Google Login</button>
      <button @click="logout">Logout</button>
    </div>

    <p class="uid">{{ uid ? `UID: ${uid}` : "로그인 안됨" }}</p>

    <div class="row">
      <button @click="addEvent">일정 추가</button>
      <button @click="fetchEvents">일정 조회</button>
    </div>

    <div class="card">
      <div class="row space">
        <button @click="prevMonth">이전</button>
        <h3>{{ year() }}년 {{ month() + 1 }}월</h3>
        <button @click="nextMonth">다음</button>
      </div>

      <div class="calendar">
        <div
          v-for="day in days"
          :key="formatDate(day)"
          class="day"
          :class="[
            getDayClass(day),
            selectedDate === formatDate(day) ? 'active' : ''
          ]"
          @click="selectDate(day)"
        >
          {{ day.getDate() }}
        </div>
      </div>
    </div>

    <div v-if="selectedDate" class="card">
      <h3>{{ selectedDate }} 일정</h3>

      <ul v-if="filteredEvents.length">
        <li v-for="event in filteredEvents" :key="event.id">
          {{ event.title }}
          ({{ event.startTime }} ~ {{ event.endTime }})
          <button @click="updateEvent(event.id)">수정</button>
          <button class="danger" @click="deleteEvent(event.id)">삭제</button>
        </li>
      </ul>

      <p v-else class="empty">일정이 없습니다</p>
    </div>
  </div>
</template>

<style>
.page {
  padding: 24px;
  background: #fff;
}

:root {
  --point: #4a6fa5;
}

.row {
  display: flex;
  gap: 12px;
  margin-bottom: 12px;
  align-items: center;
}

.row.space {
  justify-content: space-between;
}

button {
  background: var(--point);
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 8px 14px;
  cursor: pointer;
}

button.danger {
  background: #ff4d4f;
}

button:hover {
  opacity: 0.9;
}

.uid {
  font-size: 12px;
  color: #666;
}

.card {
  background: #fff;
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.calendar {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 8px;
}

.day {
  padding: 12px;
  border: 1px solid #ddd;
  text-align: center;
  cursor: pointer;
  border-radius: 6px;
}

.day:hover {
  background: #f2f4f7;
}

.day.active {
  background: var(--point);
  color: #fff;
}

.weekday { color: #000; }
.saturday { color: #2f6fff; }
.sunday { color: #ff4d4f; }

.empty {
  color: #888;
}
</style>
