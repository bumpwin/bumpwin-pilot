import * as objectTableCounter from "./object_table_counter/structs";
import * as tleCounter from "./tle_counter/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) { loader.register(objectTableCounter.Counter);
loader.register(objectTableCounter.Root);
loader.register(objectTableCounter.NewCounterEvent);
loader.register(objectTableCounter.IncrementEvent);
loader.register(tleCounter.Counter);
 }
