import type { StructClassLoader } from '../_framework/loader';
import * as cap from './cap/structs';
import * as messaging from './messaging/structs';

export function registerClasses(loader: StructClassLoader) {
  loader.register(cap.MessageFeeCap);
  loader.register(cap.AdminCap);
  loader.register(messaging.MessageReceivedEvent);
}
