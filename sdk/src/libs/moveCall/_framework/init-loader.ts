import * as package_source_1 from '../_dependencies/source/0x1/init';
import * as package_source_2 from '../sui/init';
import { StructClassLoader } from './loader';

function registerClassesSource(loader: StructClassLoader) {
  package_source_1.registerClasses(loader);
  package_source_2.registerClasses(loader);
}

export function registerClasses(loader: StructClassLoader) {
  registerClassesSource(loader);
}
