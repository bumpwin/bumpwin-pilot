import * as package_onchain_1 from '../_dependencies/onchain/0x1/init';
import * as package_onchain_2 from '../_dependencies/onchain/0x2/init';
import * as package_source_1 from '../_dependencies/source/0x1/init';
import * as package_onchain_ecce1d586efcab4a00e4a41ca40dd19c4e1d0363f2d62c332cc96801821e575 from '../ooze_fam_factory/init';
import * as package_source_2 from '../sui/init';
import { StructClassLoader } from './loader';

function registerClassesSource(loader: StructClassLoader) {
  package_source_1.registerClasses(loader);
  package_source_2.registerClasses(loader);
}

function registerClassesOnchain(loader: StructClassLoader) {
  package_onchain_1.registerClasses(loader);
  package_onchain_2.registerClasses(loader);
  package_onchain_ecce1d586efcab4a00e4a41ca40dd19c4e1d0363f2d62c332cc96801821e575.registerClasses(
    loader
  );
}

export function registerClasses(loader: StructClassLoader) {
  registerClassesOnchain(loader);
  registerClassesSource(loader);
}
