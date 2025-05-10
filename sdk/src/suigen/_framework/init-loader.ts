import * as package_onchain_1 from '../_dependencies/onchain/0x1/init';
import * as package_onchain_2 from '../_dependencies/onchain/0x2/init';
import * as package_source_1 from '../_dependencies/source/0x1/init';
import * as package_onchain_cdba49a915244851254c8bb702cee967efd55a80f36fb384a9576788c9186058 from '../bump_fam_factory/init';
import * as package_onchain_366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3 from '../justchat/init';
import * as package_source_2 from '../sui/init';
import type { StructClassLoader } from './loader';

function registerClassesSource(loader: StructClassLoader) {
  package_source_1.registerClasses(loader);
  package_source_2.registerClasses(loader);
}

function registerClassesOnchain(loader: StructClassLoader) {
  package_onchain_1.registerClasses(loader);
  package_onchain_2.registerClasses(loader);
  package_onchain_366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3.registerClasses(
    loader
  );
  package_onchain_cdba49a915244851254c8bb702cee967efd55a80f36fb384a9576788c9186058.registerClasses(
    loader
  );
}

export function registerClasses(loader: StructClassLoader) {
  registerClassesOnchain(loader);
  registerClassesSource(loader);
}
