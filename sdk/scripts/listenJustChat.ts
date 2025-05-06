import WebSocket from 'ws';

const ws = new WebSocket('wss://fullnode.testnet.sui.io:443');

ws.on('open', () => {
  console.log('🟢 Connected to Sui WebSocket');

  // イベント購読のリクエストを送信
  ws.send(JSON.stringify({
    jsonrpc: '2.0',
    id: 1,
    method: 'sui_subscribeEvent',
    params: [{
      filter: {
        MoveEventType: 'justchat::messaging::MessageReceivedEvent',
      },
    }],
  }));
});

ws.on('message', (data) => {
  const event = JSON.parse(data.toString());
  if (event.params?.result) {
    console.log('📨 New Event:', event.params.result);
  }
});

ws.on('error', (error) => {
  console.error('❌ WebSocket Error:', error);
});

ws.on('close', () => {
  console.log('🔴 WebSocket Connection Closed');
  // 再接続を試みる
  setTimeout(() => {
    console.log('🔄 Reconnecting...');
    new WebSocket('wss://fullnode.testnet.sui.io:443');
  }, 5000);
});
