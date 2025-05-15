import * as objectTableCounter from './object-table-counter/structs';
import * as tleCounter from './tle-counter/structs';
import { StructClassLoader } from '../_framework/loader';

export function registerClasses(loader: StructClassLoader) {
  loader.register(objectTableCounter.Counter);
  loader.register(objectTableCounter.Root);
  loader.register(objectTableCounter.NewCounterEvent);
  loader.register(objectTableCounter.IncrementEvent);
  loader.register(tleCounter.Counter);
}
