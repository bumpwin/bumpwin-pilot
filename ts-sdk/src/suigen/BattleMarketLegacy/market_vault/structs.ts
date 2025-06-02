import * as reified from "../../_framework/reified";
import {Balance, Supply} from "../../_dependencies/onchain/0x2/balance/structs";
import {UID} from "../../_dependencies/onchain/0x2/object/structs";
import {ObjectBag} from "../../_dependencies/onchain/0x2/object_bag/structs";
import {SUI} from "../../_dependencies/onchain/0x2/sui/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom, ToTypeStr as ToPhantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType, parseTypeName} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== MarketToken =============================== */

export function isMarketToken(type: string): boolean { type = compressSuiType(type); return type.startsWith(`${PKG_V1}::market_vault::MarketToken` + '<'); }

export interface MarketTokenFields<T0 extends PhantomTypeArgument> { dummyField: ToField<"bool"> }

export type MarketTokenReified<T0 extends PhantomTypeArgument> = Reified< MarketToken<T0>, MarketTokenFields<T0> >;

export class MarketToken<T0 extends PhantomTypeArgument> implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::market_vault::MarketToken`; static readonly $numTypeParams = 1; static readonly $isPhantom = [true,] as const;

 readonly $typeName = MarketToken.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::market_vault::MarketToken<${PhantomToTypeStr<T0>}>`; readonly $typeArgs: [PhantomToTypeStr<T0>]; readonly $isPhantom = MarketToken.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: MarketTokenFields<T0>, ) { this.$fullTypeName = composeSuiType( MarketToken.$typeName, ...typeArgs ) as `${typeof PKG_V1}::market_vault::MarketToken<${PhantomToTypeStr<T0>}>`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified<T0 extends PhantomReified<PhantomTypeArgument>>( T0: T0 ): MarketTokenReified<ToPhantomTypeArgument<T0>> { return { typeName: MarketToken.$typeName, fullTypeName: composeSuiType( MarketToken.$typeName, ...[extractType(T0)] ) as `${typeof PKG_V1}::market_vault::MarketToken<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`, typeArgs: [ extractType(T0) ] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>], isPhantom: MarketToken.$isPhantom, reifiedTypeArgs: [T0], fromFields: (fields: Record<string, any>) => MarketToken.fromFields( T0, fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => MarketToken.fromFieldsWithTypes( T0, item, ), fromBcs: (data: Uint8Array) => MarketToken.fromBcs( T0, data, ), bcs: MarketToken.bcs, fromJSONField: (field: any) => MarketToken.fromJSONField( T0, field, ), fromJSON: (json: Record<string, any>) => MarketToken.fromJSON( T0, json, ), fromSuiParsedData: (content: SuiParsedData) => MarketToken.fromSuiParsedData( T0, content, ), fromSuiObjectData: (content: SuiObjectData) => MarketToken.fromSuiObjectData( T0, content, ), fetch: async (client: SuiClient, id: string) => MarketToken.fetch( client, T0, id, ), new: ( fields: MarketTokenFields<ToPhantomTypeArgument<T0>>, ) => { return new MarketToken( [extractType(T0)], fields ) }, kind: "StructClassReified", } }

 static get r() { return MarketToken.reified }

 static phantom<T0 extends PhantomReified<PhantomTypeArgument>>( T0: T0 ): PhantomReified<ToTypeStr<MarketToken<ToPhantomTypeArgument<T0>>>> { return phantom(MarketToken.reified( T0 )); } static get p() { return MarketToken.phantom }

 static get bcs() { return bcs.struct("MarketToken", {

 dummy_field: bcs.bool()

}) };

 static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, fields: Record<string, any> ): MarketToken<ToPhantomTypeArgument<T0>> { return MarketToken.reified( typeArg, ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, item: FieldsWithTypes ): MarketToken<ToPhantomTypeArgument<T0>> { if (!isMarketToken(item.type)) { throw new Error("not a MarketToken type");

 } assertFieldsWithTypesArgsMatch(item, [typeArg]);

 return MarketToken.reified( typeArg, ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, data: Uint8Array ): MarketToken<ToPhantomTypeArgument<T0>> { return MarketToken.fromFields( typeArg, MarketToken.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, field: any ): MarketToken<ToPhantomTypeArgument<T0>> { return MarketToken.reified( typeArg, ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, json: Record<string, any> ): MarketToken<ToPhantomTypeArgument<T0>> { if (json.$typeName !== MarketToken.$typeName) { throw new Error("not a WithTwoGenerics json object") }; assertReifiedTypeArgsMatch( composeSuiType(MarketToken.$typeName, extractType(typeArg)), json.$typeArgs, [typeArg], )

 return MarketToken.fromJSONField( typeArg, json, ) }

 static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, content: SuiParsedData ): MarketToken<ToPhantomTypeArgument<T0>> { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isMarketToken(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a MarketToken object`); } return MarketToken.fromFieldsWithTypes( typeArg, content ); }

 static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, data: SuiObjectData ): MarketToken<ToPhantomTypeArgument<T0>> { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isMarketToken(data.bcs.type)) { throw new Error(`object at is not a MarketToken object`); }

 const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs; if (gotTypeArgs.length !== 1) { throw new Error(`type argument mismatch: expected 1 type argument but got '${gotTypeArgs.length}'`); }; const gotTypeArg = compressSuiType(gotTypeArgs[0]); const expectedTypeArg = compressSuiType(extractType(typeArg)); if (gotTypeArg !== compressSuiType(extractType(typeArg))) { throw new Error(`type argument mismatch: expected '${expectedTypeArg}' but got '${gotTypeArg}'`); };

 return MarketToken.fromBcs( typeArg, fromB64(data.bcs.bcsBytes) ); } if (data.content) { return MarketToken.fromSuiParsedData( typeArg, data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>( client: SuiClient, typeArg: T0, id: string ): Promise<MarketToken<ToPhantomTypeArgument<T0>>> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching MarketToken object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isMarketToken(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a MarketToken object`); }

 return MarketToken.fromSuiObjectData( typeArg, res.data ); }

 }

/* ============================== MarketVault =============================== */

export function isMarketVault(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::market_vault::MarketVault`; }

export interface MarketVaultFields { id: ToField<UID>; numeraireReserve: ToField<Balance<ToPhantom<SUI>>>; supplyBag: ToField<ObjectBag>; numOutcomes: ToField<"u64">; totalShares: ToField<"u128"> }

export type MarketVaultReified = Reified< MarketVault, MarketVaultFields >;

export class MarketVault implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::market_vault::MarketVault`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = MarketVault.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::market_vault::MarketVault`; readonly $typeArgs: []; readonly $isPhantom = MarketVault.$isPhantom;

 readonly id: ToField<UID>; readonly numeraireReserve: ToField<Balance<ToPhantom<SUI>>>; readonly supplyBag: ToField<ObjectBag>; readonly numOutcomes: ToField<"u64">; readonly totalShares: ToField<"u128">

 private constructor(typeArgs: [], fields: MarketVaultFields, ) { this.$fullTypeName = composeSuiType( MarketVault.$typeName, ...typeArgs ) as `${typeof PKG_V1}::market_vault::MarketVault`; this.$typeArgs = typeArgs;

 this.id = fields.id;; this.numeraireReserve = fields.numeraireReserve;; this.supplyBag = fields.supplyBag;; this.numOutcomes = fields.numOutcomes;; this.totalShares = fields.totalShares; }

 static reified( ): MarketVaultReified { return { typeName: MarketVault.$typeName, fullTypeName: composeSuiType( MarketVault.$typeName, ...[] ) as `${typeof PKG_V1}::market_vault::MarketVault`, typeArgs: [ ] as [], isPhantom: MarketVault.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => MarketVault.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => MarketVault.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => MarketVault.fromBcs( data, ), bcs: MarketVault.bcs, fromJSONField: (field: any) => MarketVault.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => MarketVault.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => MarketVault.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => MarketVault.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => MarketVault.fetch( client, id, ), new: ( fields: MarketVaultFields, ) => { return new MarketVault( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return MarketVault.reified() }

 static phantom( ): PhantomReified<ToTypeStr<MarketVault>> { return phantom(MarketVault.reified( )); } static get p() { return MarketVault.phantom() }

 static get bcs() { return bcs.struct("MarketVault", {

 id: UID.bcs, numeraire_reserve: Balance.bcs, supply_bag: ObjectBag.bcs, num_outcomes: bcs.u64(), total_shares: bcs.u128()

}) };

 static fromFields( fields: Record<string, any> ): MarketVault { return MarketVault.reified( ).new( { id: decodeFromFields(UID.reified(), fields.id), numeraireReserve: decodeFromFields(Balance.reified(reified.phantom(SUI.reified())), fields.numeraire_reserve), supplyBag: decodeFromFields(ObjectBag.reified(), fields.supply_bag), numOutcomes: decodeFromFields("u64", fields.num_outcomes), totalShares: decodeFromFields("u128", fields.total_shares) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): MarketVault { if (!isMarketVault(item.type)) { throw new Error("not a MarketVault type");

 }

 return MarketVault.reified( ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), numeraireReserve: decodeFromFieldsWithTypes(Balance.reified(reified.phantom(SUI.reified())), item.fields.numeraire_reserve), supplyBag: decodeFromFieldsWithTypes(ObjectBag.reified(), item.fields.supply_bag), numOutcomes: decodeFromFieldsWithTypes("u64", item.fields.num_outcomes), totalShares: decodeFromFieldsWithTypes("u128", item.fields.total_shares) } ) }

 static fromBcs( data: Uint8Array ): MarketVault { return MarketVault.fromFields( MarketVault.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,numeraireReserve: this.numeraireReserve.toJSONField(),supplyBag: this.supplyBag.toJSONField(),numOutcomes: this.numOutcomes.toString(),totalShares: this.totalShares.toString(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): MarketVault { return MarketVault.reified( ).new( { id: decodeFromJSONField(UID.reified(), field.id), numeraireReserve: decodeFromJSONField(Balance.reified(reified.phantom(SUI.reified())), field.numeraireReserve), supplyBag: decodeFromJSONField(ObjectBag.reified(), field.supplyBag), numOutcomes: decodeFromJSONField("u64", field.numOutcomes), totalShares: decodeFromJSONField("u128", field.totalShares) } ) }

 static fromJSON( json: Record<string, any> ): MarketVault { if (json.$typeName !== MarketVault.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return MarketVault.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): MarketVault { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isMarketVault(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a MarketVault object`); } return MarketVault.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): MarketVault { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isMarketVault(data.bcs.type)) { throw new Error(`object at is not a MarketVault object`); }

 return MarketVault.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return MarketVault.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<MarketVault> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching MarketVault object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isMarketVault(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a MarketVault object`); }

 return MarketVault.fromSuiObjectData( res.data ); }

 }

/* ============================== TokenSupply =============================== */

export function isTokenSupply(type: string): boolean { type = compressSuiType(type); return type.startsWith(`${PKG_V1}::market_vault::TokenSupply` + '<'); }

export interface TokenSupplyFields<T0 extends PhantomTypeArgument> { id: ToField<UID>; supply: ToField<Supply<ToPhantom<MarketToken<T0>>>> }

export type TokenSupplyReified<T0 extends PhantomTypeArgument> = Reified< TokenSupply<T0>, TokenSupplyFields<T0> >;

export class TokenSupply<T0 extends PhantomTypeArgument> implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::market_vault::TokenSupply`; static readonly $numTypeParams = 1; static readonly $isPhantom = [true,] as const;

 readonly $typeName = TokenSupply.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::market_vault::TokenSupply<${PhantomToTypeStr<T0>}>`; readonly $typeArgs: [PhantomToTypeStr<T0>]; readonly $isPhantom = TokenSupply.$isPhantom;

 readonly id: ToField<UID>; readonly supply: ToField<Supply<ToPhantom<MarketToken<T0>>>>

 private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: TokenSupplyFields<T0>, ) { this.$fullTypeName = composeSuiType( TokenSupply.$typeName, ...typeArgs ) as `${typeof PKG_V1}::market_vault::TokenSupply<${PhantomToTypeStr<T0>}>`; this.$typeArgs = typeArgs;

 this.id = fields.id;; this.supply = fields.supply; }

 static reified<T0 extends PhantomReified<PhantomTypeArgument>>( T0: T0 ): TokenSupplyReified<ToPhantomTypeArgument<T0>> { return { typeName: TokenSupply.$typeName, fullTypeName: composeSuiType( TokenSupply.$typeName, ...[extractType(T0)] ) as `${typeof PKG_V1}::market_vault::TokenSupply<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`, typeArgs: [ extractType(T0) ] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>], isPhantom: TokenSupply.$isPhantom, reifiedTypeArgs: [T0], fromFields: (fields: Record<string, any>) => TokenSupply.fromFields( T0, fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => TokenSupply.fromFieldsWithTypes( T0, item, ), fromBcs: (data: Uint8Array) => TokenSupply.fromBcs( T0, data, ), bcs: TokenSupply.bcs, fromJSONField: (field: any) => TokenSupply.fromJSONField( T0, field, ), fromJSON: (json: Record<string, any>) => TokenSupply.fromJSON( T0, json, ), fromSuiParsedData: (content: SuiParsedData) => TokenSupply.fromSuiParsedData( T0, content, ), fromSuiObjectData: (content: SuiObjectData) => TokenSupply.fromSuiObjectData( T0, content, ), fetch: async (client: SuiClient, id: string) => TokenSupply.fetch( client, T0, id, ), new: ( fields: TokenSupplyFields<ToPhantomTypeArgument<T0>>, ) => { return new TokenSupply( [extractType(T0)], fields ) }, kind: "StructClassReified", } }

 static get r() { return TokenSupply.reified }

 static phantom<T0 extends PhantomReified<PhantomTypeArgument>>( T0: T0 ): PhantomReified<ToTypeStr<TokenSupply<ToPhantomTypeArgument<T0>>>> { return phantom(TokenSupply.reified( T0 )); } static get p() { return TokenSupply.phantom }

 static get bcs() { return bcs.struct("TokenSupply", {

 id: UID.bcs, supply: Supply.bcs

}) };

 static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, fields: Record<string, any> ): TokenSupply<ToPhantomTypeArgument<T0>> { return TokenSupply.reified( typeArg, ).new( { id: decodeFromFields(UID.reified(), fields.id), supply: decodeFromFields(Supply.reified(reified.phantom(MarketToken.reified(typeArg))), fields.supply) } ) }

 static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, item: FieldsWithTypes ): TokenSupply<ToPhantomTypeArgument<T0>> { if (!isTokenSupply(item.type)) { throw new Error("not a TokenSupply type");

 } assertFieldsWithTypesArgsMatch(item, [typeArg]);

 return TokenSupply.reified( typeArg, ).new( { id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), supply: decodeFromFieldsWithTypes(Supply.reified(reified.phantom(MarketToken.reified(typeArg))), item.fields.supply) } ) }

 static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, data: Uint8Array ): TokenSupply<ToPhantomTypeArgument<T0>> { return TokenSupply.fromFields( typeArg, TokenSupply.bcs.parse(data) ) }

 toJSONField() { return {

 id: this.id,supply: this.supply.toJSONField(),

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, field: any ): TokenSupply<ToPhantomTypeArgument<T0>> { return TokenSupply.reified( typeArg, ).new( { id: decodeFromJSONField(UID.reified(), field.id), supply: decodeFromJSONField(Supply.reified(reified.phantom(MarketToken.reified(typeArg))), field.supply) } ) }

 static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, json: Record<string, any> ): TokenSupply<ToPhantomTypeArgument<T0>> { if (json.$typeName !== TokenSupply.$typeName) { throw new Error("not a WithTwoGenerics json object") }; assertReifiedTypeArgsMatch( composeSuiType(TokenSupply.$typeName, extractType(typeArg)), json.$typeArgs, [typeArg], )

 return TokenSupply.fromJSONField( typeArg, json, ) }

 static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, content: SuiParsedData ): TokenSupply<ToPhantomTypeArgument<T0>> { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isTokenSupply(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a TokenSupply object`); } return TokenSupply.fromFieldsWithTypes( typeArg, content ); }

 static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>( typeArg: T0, data: SuiObjectData ): TokenSupply<ToPhantomTypeArgument<T0>> { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isTokenSupply(data.bcs.type)) { throw new Error(`object at is not a TokenSupply object`); }

 const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs; if (gotTypeArgs.length !== 1) { throw new Error(`type argument mismatch: expected 1 type argument but got '${gotTypeArgs.length}'`); }; const gotTypeArg = compressSuiType(gotTypeArgs[0]); const expectedTypeArg = compressSuiType(extractType(typeArg)); if (gotTypeArg !== compressSuiType(extractType(typeArg))) { throw new Error(`type argument mismatch: expected '${expectedTypeArg}' but got '${gotTypeArg}'`); };

 return TokenSupply.fromBcs( typeArg, fromB64(data.bcs.bcsBytes) ); } if (data.content) { return TokenSupply.fromSuiParsedData( typeArg, data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>( client: SuiClient, typeArg: T0, id: string ): Promise<TokenSupply<ToPhantomTypeArgument<T0>>> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching TokenSupply object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isTokenSupply(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a TokenSupply object`); }

 return TokenSupply.fromSuiObjectData( typeArg, res.data ); }

 }
