<script setup>
<<<<<<< HEAD
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <div>
    <a href="https://vite.dev" target="_blank">
      <img src="/vite.svg" class="logo" alt="Vite logo" />
    </a>
    <a href="https://vuejs.org/" target="_blank">
      <img src="./assets/vue.svg" class="logo vue" alt="Vue logo" />
    </a>
  </div>
  <HelloWorld msg="Vite + Vue" />
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style>
=======
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
  <button @click="login">Google Login</button>
  <button @click="logout">Logout</button>
</template>
>>>>>>> f9fafc0a55b6ab8efeacfffd936c421cc970f11c
