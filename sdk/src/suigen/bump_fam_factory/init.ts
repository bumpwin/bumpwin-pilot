import * as bumpFamFactory from './bump_fam_factory/structs';
import * as vault from './vault/structs';
import { StructClassLoader } from '../_framework/loader';

export function registerClasses(loader: StructClassLoader) {
  loader.register(bumpFamFactory.CreateCoinEvent);
  loader.register(vault.BumpWinCoinVault);
  loader.register(vault.AdminCap);
}
