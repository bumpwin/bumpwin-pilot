import * as package_onchain_1 from "../_dependencies/onchain/0x1/init";
import * as package_onchain_2 from "../_dependencies/onchain/0x2/init";
import * as package_onchain_f0f47c13aaa1b5ff53e4d44df713049d85515cf1c1884704b805d4523a23daec from "../_dependencies/onchain/0xf0f47c13aaa1b5ff53e4d44df713049d85515cf1c1884704b805d4523a23daec/init";
import * as package_onchain_80ded5c56a6375c887fd4357487bd7d725712694b3b4b994d224b1ff23565364 from "../battleMarket/init";
import * as package_onchain_271c2fd30fd48ed9cf5b9bb903ccfbe19398becb2cab3c65026149a6a4a956b4 from "../champMarket/init";
import * as package_onchain_1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38 from "../counter/init";
import * as package_onchain_366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3 from "../justchat/init";
import * as package_onchain_90ef72a68ca6bef409448bb474bb949d4b244baa8e2c4198bb9ec83c3dabf40e from "../mockcoins/init";
import {StructClassLoader} from "./loader";

function registerClassesOnchain(loader: StructClassLoader) { package_onchain_1.registerClasses(loader);
package_onchain_2.registerClasses(loader);
package_onchain_1d58d7a49fafb509aef183464eaa4c5d1c2f26a56f4a7eb78ddbcd3c83713a38.registerClasses(loader);
package_onchain_271c2fd30fd48ed9cf5b9bb903ccfbe19398becb2cab3c65026149a6a4a956b4.registerClasses(loader);
package_onchain_366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3.registerClasses(loader);
package_onchain_80ded5c56a6375c887fd4357487bd7d725712694b3b4b994d224b1ff23565364.registerClasses(loader);
package_onchain_90ef72a68ca6bef409448bb474bb949d4b244baa8e2c4198bb9ec83c3dabf40e.registerClasses(loader);
package_onchain_f0f47c13aaa1b5ff53e4d44df713049d85515cf1c1884704b805d4523a23daec.registerClasses(loader);
 }

export function registerClasses(loader: StructClassLoader) { registerClassesOnchain(loader); }
