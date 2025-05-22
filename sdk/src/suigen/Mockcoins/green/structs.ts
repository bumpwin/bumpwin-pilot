import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== GREEN =============================== */

export function isGREEN(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::green::GREEN`; }

export interface GREENFields { dummyField: ToField<"bool"> }

export type GREENReified = Reified< GREEN, GREENFields >;

export class GREEN implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::green::GREEN`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = GREEN.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::green::GREEN`; readonly $typeArgs: []; readonly $isPhantom = GREEN.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [], fields: GREENFields, ) { this.$fullTypeName = composeSuiType( GREEN.$typeName, ...typeArgs ) as `${typeof PKG_V1}::green::GREEN`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified( ): GREENReified { return { typeName: GREEN.$typeName, fullTypeName: composeSuiType( GREEN.$typeName, ...[] ) as `${typeof PKG_V1}::green::GREEN`, typeArgs: [ ] as [], isPhantom: GREEN.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => GREEN.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => GREEN.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => GREEN.fromBcs( data, ), bcs: GREEN.bcs, fromJSONField: (field: any) => GREEN.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => GREEN.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => GREEN.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => GREEN.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => GREEN.fetch( client, id, ), new: ( fields: GREENFields, ) => { return new GREEN( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return GREEN.reified() }

 static phantom( ): PhantomReified<ToTypeStr<GREEN>> { return phantom(GREEN.reified( )); } static get p() { return GREEN.phantom() }

 static get bcs() { return bcs.struct("GREEN", {

 dummy_field: bcs.bool()

}) };

 static fromFields( fields: Record<string, any> ): GREEN { return GREEN.reified( ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): GREEN { if (!isGREEN(item.type)) { throw new Error("not a GREEN type");

 }

 return GREEN.reified( ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs( data: Uint8Array ): GREEN { return GREEN.fromFields( GREEN.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): GREEN { return GREEN.reified( ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON( json: Record<string, any> ): GREEN { if (json.$typeName !== GREEN.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return GREEN.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): GREEN { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isGREEN(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a GREEN object`); } return GREEN.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): GREEN { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isGREEN(data.bcs.type)) { throw new Error(`object at is not a GREEN object`); }

 return GREEN.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return GREEN.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<GREEN> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching GREEN object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isGREEN(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a GREEN object`); }

 return GREEN.fromSuiObjectData( res.data ); }

 }
