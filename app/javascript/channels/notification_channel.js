consumer.subscriptions.create(
  { channel: 'NotificationChannel', user_id: currentUser.id },
  {
    connected() {
      console.log('🟢 Connected to NotificationChannel');
    },
    disconnected() {
      console.log('🔌 Disconnected from NotificationChannel');
    },
    received(data) {
      console.log('📥 Received data:', data);
      alert(data.message);
    },
  }
);
