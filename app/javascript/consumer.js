// app/javascript/channels/consumer.js
import { createConsumer } from '@rails/actioncable';

export default createConsumer();
const cable = createConsumer('wss://program-routine-mate.com/cable');
