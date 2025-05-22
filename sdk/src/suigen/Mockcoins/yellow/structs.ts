import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== YELLOW =============================== */

export function isYELLOW(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::yellow::YELLOW`; }

export interface YELLOWFields { dummyField: ToField<"bool"> }

export type YELLOWReified = Reified< YELLOW, YELLOWFields >;

export class YELLOW implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::yellow::YELLOW`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = YELLOW.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::yellow::YELLOW`; readonly $typeArgs: []; readonly $isPhantom = YELLOW.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [], fields: YELLOWFields, ) { this.$fullTypeName = composeSuiType( YELLOW.$typeName, ...typeArgs ) as `${typeof PKG_V1}::yellow::YELLOW`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified( ): YELLOWReified { return { typeName: YELLOW.$typeName, fullTypeName: composeSuiType( YELLOW.$typeName, ...[] ) as `${typeof PKG_V1}::yellow::YELLOW`, typeArgs: [ ] as [], isPhantom: YELLOW.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => YELLOW.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => YELLOW.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => YELLOW.fromBcs( data, ), bcs: YELLOW.bcs, fromJSONField: (field: any) => YELLOW.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => YELLOW.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => YELLOW.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => YELLOW.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => YELLOW.fetch( client, id, ), new: ( fields: YELLOWFields, ) => { return new YELLOW( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return YELLOW.reified() }

 static phantom( ): PhantomReified<ToTypeStr<YELLOW>> { return phantom(YELLOW.reified( )); } static get p() { return YELLOW.phantom() }

 static get bcs() { return bcs.struct("YELLOW", {

 dummy_field: bcs.bool()

}) };

 static fromFields( fields: Record<string, any> ): YELLOW { return YELLOW.reified( ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): YELLOW { if (!isYELLOW(item.type)) { throw new Error("not a YELLOW type");

 }

 return YELLOW.reified( ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs( data: Uint8Array ): YELLOW { return YELLOW.fromFields( YELLOW.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): YELLOW { return YELLOW.reified( ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON( json: Record<string, any> ): YELLOW { if (json.$typeName !== YELLOW.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return YELLOW.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): YELLOW { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isYELLOW(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a YELLOW object`); } return YELLOW.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): YELLOW { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isYELLOW(data.bcs.type)) { throw new Error(`object at is not a YELLOW object`); }

 return YELLOW.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return YELLOW.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<YELLOW> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching YELLOW object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isYELLOW(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a YELLOW object`); }

 return YELLOW.fromSuiObjectData( res.data ); }

 }
