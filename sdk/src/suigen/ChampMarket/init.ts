import * as cpmm from './cpmm/structs';
import * as root from './root/structs';
import { StructClassLoader } from '../_framework/loader';

export function registerClasses(loader: StructClassLoader) {
  loader.register(cpmm.Pool);
  loader.register(cpmm.SwapEvent);
  loader.register(root.Root);
}
