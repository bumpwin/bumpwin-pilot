import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== WHITE =============================== */

export function isWHITE(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::white::WHITE`; }

export interface WHITEFields { dummyField: ToField<"bool"> }

export type WHITEReified = Reified< WHITE, WHITEFields >;

export class WHITE implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::white::WHITE`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = WHITE.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::white::WHITE`; readonly $typeArgs: []; readonly $isPhantom = WHITE.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [], fields: WHITEFields, ) { this.$fullTypeName = composeSuiType( WHITE.$typeName, ...typeArgs ) as `${typeof PKG_V1}::white::WHITE`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified( ): WHITEReified { return { typeName: WHITE.$typeName, fullTypeName: composeSuiType( WHITE.$typeName, ...[] ) as `${typeof PKG_V1}::white::WHITE`, typeArgs: [ ] as [], isPhantom: WHITE.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => WHITE.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => WHITE.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => WHITE.fromBcs( data, ), bcs: WHITE.bcs, fromJSONField: (field: any) => WHITE.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => WHITE.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => WHITE.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => WHITE.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => WHITE.fetch( client, id, ), new: ( fields: WHITEFields, ) => { return new WHITE( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return WHITE.reified() }

 static phantom( ): PhantomReified<ToTypeStr<WHITE>> { return phantom(WHITE.reified( )); } static get p() { return WHITE.phantom() }

 static get bcs() { return bcs.struct("WHITE", {

 dummy_field: bcs.bool()

}) };

 static fromFields( fields: Record<string, any> ): WHITE { return WHITE.reified( ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): WHITE { if (!isWHITE(item.type)) { throw new Error("not a WHITE type");

 }

 return WHITE.reified( ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs( data: Uint8Array ): WHITE { return WHITE.fromFields( WHITE.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): WHITE { return WHITE.reified( ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON( json: Record<string, any> ): WHITE { if (json.$typeName !== WHITE.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return WHITE.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): WHITE { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isWHITE(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a WHITE object`); } return WHITE.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): WHITE { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isWHITE(data.bcs.type)) { throw new Error(`object at is not a WHITE object`); }

 return WHITE.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return WHITE.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<WHITE> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching WHITE object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isWHITE(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a WHITE object`); }

 return WHITE.fromSuiObjectData( res.data ); }

 }
