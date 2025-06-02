import * as marketVault from "./market_vault/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) { loader.register(marketVault.MarketToken);
loader.register(marketVault.MarketVault);
loader.register(marketVault.TokenSupply);
 }
