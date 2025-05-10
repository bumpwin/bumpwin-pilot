import type { StructClassLoader } from '../_framework/loader';
import * as bumpFamFactory from './bump-fam-factory/structs';
import * as vault from './vault/structs';

export function registerClasses(loader: StructClassLoader) {
  loader.register(bumpFamFactory.CreateCoinEvent);
  loader.register(vault.BumpWinCoinVault);
  loader.register(vault.AdminCap);
}
