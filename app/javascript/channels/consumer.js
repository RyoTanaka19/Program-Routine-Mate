// Action Cableのコンシューマーを作成します。
// このファイルは、WebSocket接続を通じてリアルタイム機能を提供するために使用されます。
// createConsumer() を使用することで、サーバーとのWebSocket接続が確立され、
// チャンネルとの通信が可能になります。

import { createConsumer } from '@rails/actioncable';

// WebSocket接続を初期化してエクスポートします。
// 他のモジュールでこのconsumerを使用することで、
// 任意のチャンネルに購読したり、リアルタイムデータを受信したりできます。
export default createConsumer();
