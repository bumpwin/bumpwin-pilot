import * as blue from './blue/structs';
import * as green from './green/structs';
import * as red from './red/structs';
import { StructClassLoader } from '../_framework/loader';

export function registerClasses(loader: StructClassLoader) {
  loader.register(blue.BLUE);
  loader.register(green.GREEN);
  loader.register(red.RED);
}
