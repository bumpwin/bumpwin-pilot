import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {PKG_V1} from "../constants";
import {bcs} from "@mysten/sui/bcs";
import {SuiClient, SuiObjectData, SuiParsedData} from "@mysten/sui/client";
import {fromB64} from "@mysten/sui/utils";

/* ============================== RED =============================== */

export function isRED(type: string): boolean { type = compressSuiType(type); return type === `${PKG_V1}::red::RED`; }

export interface REDFields { dummyField: ToField<"bool"> }

export type REDReified = Reified< RED, REDFields >;

export class RED implements StructClass { __StructClass = true as const;

 static readonly $typeName = `${PKG_V1}::red::RED`; static readonly $numTypeParams = 0; static readonly $isPhantom = [] as const;

 readonly $typeName = RED.$typeName; readonly $fullTypeName: `${typeof PKG_V1}::red::RED`; readonly $typeArgs: []; readonly $isPhantom = RED.$isPhantom;

 readonly dummyField: ToField<"bool">

 private constructor(typeArgs: [], fields: REDFields, ) { this.$fullTypeName = composeSuiType( RED.$typeName, ...typeArgs ) as `${typeof PKG_V1}::red::RED`; this.$typeArgs = typeArgs;

 this.dummyField = fields.dummyField; }

 static reified( ): REDReified { return { typeName: RED.$typeName, fullTypeName: composeSuiType( RED.$typeName, ...[] ) as `${typeof PKG_V1}::red::RED`, typeArgs: [ ] as [], isPhantom: RED.$isPhantom, reifiedTypeArgs: [], fromFields: (fields: Record<string, any>) => RED.fromFields( fields, ), fromFieldsWithTypes: (item: FieldsWithTypes) => RED.fromFieldsWithTypes( item, ), fromBcs: (data: Uint8Array) => RED.fromBcs( data, ), bcs: RED.bcs, fromJSONField: (field: any) => RED.fromJSONField( field, ), fromJSON: (json: Record<string, any>) => RED.fromJSON( json, ), fromSuiParsedData: (content: SuiParsedData) => RED.fromSuiParsedData( content, ), fromSuiObjectData: (content: SuiObjectData) => RED.fromSuiObjectData( content, ), fetch: async (client: SuiClient, id: string) => RED.fetch( client, id, ), new: ( fields: REDFields, ) => { return new RED( [], fields ) }, kind: "StructClassReified", } }

 static get r() { return RED.reified() }

 static phantom( ): PhantomReified<ToTypeStr<RED>> { return phantom(RED.reified( )); } static get p() { return RED.phantom() }

 static get bcs() { return bcs.struct("RED", {

 dummy_field: bcs.bool()

}) };

 static fromFields( fields: Record<string, any> ): RED { return RED.reified( ).new( { dummyField: decodeFromFields("bool", fields.dummy_field) } ) }

 static fromFieldsWithTypes( item: FieldsWithTypes ): RED { if (!isRED(item.type)) { throw new Error("not a RED type");

 }

 return RED.reified( ).new( { dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field) } ) }

 static fromBcs( data: Uint8Array ): RED { return RED.fromFields( RED.bcs.parse(data) ) }

 toJSONField() { return {

 dummyField: this.dummyField,

} }

 toJSON() { return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() } }

 static fromJSONField( field: any ): RED { return RED.reified( ).new( { dummyField: decodeFromJSONField("bool", field.dummyField) } ) }

 static fromJSON( json: Record<string, any> ): RED { if (json.$typeName !== RED.$typeName) { throw new Error("not a WithTwoGenerics json object") };

 return RED.fromJSONField( json, ) }

 static fromSuiParsedData( content: SuiParsedData ): RED { if (content.dataType !== "moveObject") { throw new Error("not an object"); } if (!isRED(content.type)) { throw new Error(`object at ${(content.fields as any).id} is not a RED object`); } return RED.fromFieldsWithTypes( content ); }

 static fromSuiObjectData( data: SuiObjectData ): RED { if (data.bcs) { if (data.bcs.dataType !== "moveObject" || !isRED(data.bcs.type)) { throw new Error(`object at is not a RED object`); }

 return RED.fromBcs( fromB64(data.bcs.bcsBytes) ); } if (data.content) { return RED.fromSuiParsedData( data.content ) } throw new Error( "Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request." ); }

 static async fetch( client: SuiClient, id: string ): Promise<RED> { const res = await client.getObject({ id, options: { showBcs: true, }, }); if (res.error) { throw new Error(`error fetching RED object at id ${id}: ${res.error.code}`); } if (res.data?.bcs?.dataType !== "moveObject" || !isRED(res.data.bcs.type)) { throw new Error(`object at id ${id} is not a RED object`); }

 return RED.fromSuiObjectData( res.data ); }

 }
