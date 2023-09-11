importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js');
importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-firestore.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyCRXBni4JS6S8Iz5_nZMAXgCHrcweY6we0",
    authDomain: "chat-app-502c1.firebaseapp.com",
    databaseURL: "https://chat-app-502c1-default-rtdb.firebaseio.com",
    projectId: "chat-app-502c1",
    storageBucket: "chat-app-502c1.appspot.com",
    messagingSenderId: "591699803839",
    appId: "1:591699803839:web:299f176d6410733a7d500a"
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });