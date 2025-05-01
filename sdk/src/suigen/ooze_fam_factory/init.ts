import * as oozeFamFactory from './ooze-fam-factory/structs';
import { StructClassLoader } from '../_framework/loader';

export function registerClasses(loader: StructClassLoader) {
  loader.register(oozeFamFactory.OozeFamVault);
}
