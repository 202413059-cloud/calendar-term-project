<script setup>
import { auth } from "./firebase";
import { GoogleAuthProvider, signInWithPopup, signOut } from "firebase/auth";

const provider = new GoogleAuthProvider();

const login = async () => {
  const result = await signInWithPopup(auth, provider);
  console.log(result.user.uid);
};

const logout = async () => {
  await signOut(auth);
};
</script>

<template>
  <div>
    <button @click="login">Google Login</button>
    <button @click="logout">Logout</button>
  </div>
</template>
