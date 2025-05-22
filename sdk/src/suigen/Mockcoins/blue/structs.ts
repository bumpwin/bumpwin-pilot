import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== BLUE =============================== */

export function isBLUE(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::blue::BLUE`; }

export interface BLUEFields { dummyField: ToField<"bool"> }

export type BLUEReified = Reified< BLUE, BLUEFields >;

export class BLUE implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::blue::BLUE`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = BLUE.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::blue::BLUE`; readonly $typeArgs: []; readonly $isPhantom = BLUE.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [], fields: BLUEFields, ) { this.$fullTypeName = composeSuiType( BLUE.$typeName, ...typeArgs ) as `${typeof PKG_V1}::blue::BLUE`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified( ): BLUEReified { return { typeName: BLUE.$typeName, fullTypeName: composeSuiType( BLUE.$typeName, ...[] ) as `${typeof PKG_V1}::blue::BLUE`, typeArgs: [ ] as [], isPhantom: BLUE.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => BLUE.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => BLUE.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => BLUE.fromBcs( data, ), bcs: BLUE.bcs, fromJSONField: (field: any) => BLUE.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => BLUE.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => BLUE.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => BLUE.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => BLUE.fetch( client, id, ), new: ( fields: BLUEFields, ) => { return new BLUE( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return BLUE.reified() }

 static phantom( ): PhantomReified<ToTypeStr<BLUE>> { return phantom(BLUE.reified( )); } static get p() { return BLUE.phantom() }

 static get bcs() { return bcs.struct("BLUE", {

 dummy_field: bcs.bool()

}) };

 static fromFields( fields: Record<string, any> ): BLUE { return BLUE.reified( ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): BLUE { if (!isBLUE(item.type)) { throw new Error("not a BLUE type");

 }

 return BLUE.reified( ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs( data: Uint8Array ): BLUE { return BLUE.fromFields( BLUE.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): BLUE { return BLUE.reified( ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON( json: Record<string, any> ): BLUE { if (json.$typeName !== BLUE.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return BLUE.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): BLUE { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isBLUE(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a BLUE object`); } return BLUE.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): BLUE { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isBLUE(data.bcs.type)) { throw new Error(`object at is not a BLUE object`); }

 return BLUE.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return BLUE.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<BLUE> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching BLUE object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isBLUE(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a BLUE object`); }

 return BLUE.fromSuiObjectData( res.data ); }

 }
