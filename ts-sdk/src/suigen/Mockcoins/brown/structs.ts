import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== BROWN =============================== */

export function isBROWN(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::brown::BROWN`; }

export interface BROWNFields { dummyField: ToField<"bool"> }

export type BROWNReified = Reified< BROWN, BROWNFields >;

export class BROWN implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::brown::BROWN`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = BROWN.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::brown::BROWN`; readonly $typeArgs: []; readonly $isPhantom = BROWN.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [], fields: BROWNFields, ) { this.$fullTypeName = composeSuiType( BROWN.$typeName, ...typeArgs ) as `${typeof PKG_V1}::brown::BROWN`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified( ): BROWNReified { return { typeName: BROWN.$typeName, fullTypeName: composeSuiType( BROWN.$typeName, ...[] ) as `${typeof PKG_V1}::brown::BROWN`, typeArgs: [ ] as [], isPhantom: BROWN.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => BROWN.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => BROWN.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => BROWN.fromBcs( data, ), bcs: BROWN.bcs, fromJSONField: (field: any) => BROWN.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => BROWN.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => BROWN.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => BROWN.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => BROWN.fetch( client, id, ), new: ( fields: BROWNFields, ) => { return new BROWN( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return BROWN.reified() }

 static phantom( ): PhantomReified<ToTypeStr<BROWN>> { return phantom(BROWN.reified( )); } static get p() { return BROWN.phantom() }

 static get bcs() { return bcs.struct("BROWN", {

 dummy_field: bcs.bool()

}) };

 static fromFields( fields: Record<string, any> ): BROWN { return BROWN.reified( ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): BROWN { if (!isBROWN(item.type)) { throw new Error("not a BROWN type");

 }

 return BROWN.reified( ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs( data: Uint8Array ): BROWN { return BROWN.fromFields( BROWN.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): BROWN { return BROWN.reified( ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON( json: Record<string, any> ): BROWN { if (json.$typeName !== BROWN.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return BROWN.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): BROWN { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isBROWN(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a BROWN object`); } return BROWN.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): BROWN { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isBROWN(data.bcs.type)) { throw new Error(`object at is not a BROWN object`); }

 return BROWN.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return BROWN.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<BROWN> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching BROWN object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isBROWN(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a BROWN object`); }

 return BROWN.fromSuiObjectData( res.data ); }

 }
