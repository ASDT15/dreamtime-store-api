// ws.js
const WebSocket = require('ws');

const wss = new WebSocket.Server({ noServer: true });

const broadcast = (data) => {
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });
};

module.exports = { wss, broadcast };
