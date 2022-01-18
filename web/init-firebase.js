import { initializeApp } from 'https://www.gstatic.com/firebasejs/9.4.0/firebase-app.js'
import {} from 'https://www.gstatic.com/firebasejs/9.4.0/firebase-storage.js'
import {} from 'https://www.gstatic.com/firebasejs/9.4.0/firebase-firestore.js'
import {} from 'https://www.gstatic.com/firebasejs/9.4.0/firebase-auth.js'

const firebaseConfig = {
    apiKey: "AIzaSyBao3K4w2IIBP41hxmaaOaAw8TkIiSiWTk",
    authDomain: "pascaid.firebaseapp.com",
    databaseURL: "https://pascaid-default-rtdb.firebaseio.com",
    projectId: "pascaid",
    storageBucket: "pascaid.appspot.com",
    messagingSenderId: "1029497086241",
    appId: "1:1029497086241:web:b9a5fb3bf7de1ffdad9e60",
    measurementId: "G-LC7BF1Z5X6",
};
const app = initializeApp(firebaseConfig);