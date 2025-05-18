import * as package_onchain_1 from '../_dependencies/onchain/0x1/init';
import * as package_onchain_2 from '../_dependencies/onchain/0x2/init';
import * as package_source_1 from '../_dependencies/source/0x1/init';
import * as package_onchain_cdba49a915244851254c8bb702cee967efd55a80f36fb384a9576788c9186058 from '../bump_fam_factory/init';
import * as package_onchain_41f17137266d55fe4a1c954e081fe12505a846313fae514c5064abd5e6c7181d from '../champ_market/init';
import * as package_onchain_1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38 from '../counter/init';
import * as package_onchain_366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3 from '../justchat/init';
import * as package_onchain_d8aa123529475b8bd51712972d49215a4bc75edc4bc15484ee5a019adbd27af8 from '../mockcoins/init';
import * as package_source_2 from '../sui/init';
import { StructClassLoader } from './loader';

function registerClassesSource(loader: StructClassLoader) {
  package_source_1.registerClasses(loader);
  package_source_2.registerClasses(loader);
}

function registerClassesOnchain(loader: StructClassLoader) {
  package_onchain_1.registerClasses(loader);
  package_onchain_2.registerClasses(loader);
  package_onchain_1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38.registerClasses(loader);
  package_onchain_366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3.registerClasses(loader);
  package_onchain_41f17137266d55fe4a1c954e081fe12505a846313fae514c5064abd5e6c7181d.registerClasses(loader);
  package_onchain_cdba49a915244851254c8bb702cee967efd55a80f36fb384a9576788c9186058.registerClasses(loader);
  package_onchain_d8aa123529475b8bd51712972d49215a4bc75edc4bc15484ee5a019adbd27af8.registerClasses(loader);
}

export function registerClasses(loader: StructClassLoader) {
  registerClassesOnchain(loader);
  registerClassesSource(loader);
}
