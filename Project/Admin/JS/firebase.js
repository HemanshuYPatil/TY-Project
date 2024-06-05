import { initializeApp } from "https://www.gstatic.com/firebasejs/10.6.0/firebase-app.js";
import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.6.0/firebase-analytics.js";


  const firebaseConfig = {
    apiKey: "AIzaSyD0XQO5hCpPiEcQ5xfzRrxZm21kQMh8nR4",
    authDomain: "chatbuddy-9d4f4.firebaseapp.com",
    databaseURL: "https://chatbuddy-9d4f4-default-rtdb.firebaseio.com",
    projectId: "chatbuddy-9d4f4",
    storageBucket: "chatbuddy-9d4f4.appspot.com",
    messagingSenderId: "1034615009491",
    appId: "1:1034615009491:web:457d568cba558f180a2426",
    measurementId: "G-8WL015BQ1V"
  };

  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
