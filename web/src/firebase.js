import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyAja7TMRgDRp4IYsdzM6x5r6cI1shVdbRU",
  authDomain: "calendar-term-project.firebaseapp.com",
  projectId: "calendar-term-project",
  storageBucket: "calendar-term-project.firebasestorage.app",
  messagingSenderId: "720817598270",
  appId: "1:720817598270:web:ba0700529fb7ed2550466f"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
