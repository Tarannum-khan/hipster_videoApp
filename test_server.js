// Simple WebSocket server for testing multi-device video calling
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

console.log('🚀 WebSocket server running on ws://localhost:8080');
console.log('📱 Connect your devices to the same room ID to test video calling');

wss.on('connection', (ws) => {
  console.log('📱 New device connected');
  
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data);
      console.log('📨 Message received:', message.type, 'from', message.from);
      
      // Broadcast to all other clients in the same room
      wss.clients.forEach(client => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
          client.send(data);
        }
      });
    } catch (e) {
      console.error('❌ Error parsing message:', e);
    }
  });
  
  ws.on('close', () => {
    console.log('📱 Device disconnected');
  });
});

// Keep server running
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down server...');
  wss.close();
  process.exit(0);
});








