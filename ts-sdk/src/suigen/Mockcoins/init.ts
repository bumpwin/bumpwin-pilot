import * as black from "./black/structs";
import * as blue from "./blue/structs";
import * as brown from "./brown/structs";
import * as cyan from "./cyan/structs";
import * as green from "./green/structs";
import * as pink from "./pink/structs";
import * as red from "./red/structs";
import * as white from "./white/structs";
import * as wsui from "./wsui/structs";
import * as yellow from "./yellow/structs";
import {StructClassLoader} from "../_framework/loader";

export function registerClasses(loader: StructClassLoader) { loader.register(black.BLACK);
loader.register(blue.BLUE);
loader.register(brown.BROWN);
loader.register(cyan.CYAN);
loader.register(green.GREEN);
loader.register(pink.PINK);
loader.register(red.RED);
loader.register(white.WHITE);
loader.register(wsui.WSUI);
loader.register(yellow.YELLOW);
 }
