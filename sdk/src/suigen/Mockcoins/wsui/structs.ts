import {
  PhantomReified,
  Reified,
  StructClass,
  ToField,
  ToTypeStr,
  decodeFromFields,
  decodeFromFieldsWithTypes,
  decodeFromJSONField,
  phantom,
} from '../../_framework/reified';
import { FieldsWithTypes, composeSuiType, compressSuiType } from '../../_framework/util';
import { PKG_V1 } from '../constants';
import { bcs } from '@mysten/sui/bcs';
import { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64 } from '@mysten/sui/utils';

/* ============================== WSUI =============================== */

export function isWSUI(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::wsui::WSUI`;
}

export interface WSUIFields {
  dummyField: ToField<'bool'>;
}

export type WSUIReified = Reified<WSUI, WSUIFields>;

export class WSUI implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::wsui::WSUI`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = WSUI.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::wsui::WSUI`;
  readonly $typeArgs: [];
  readonly $isPhantom = WSUI.$isPhantom;

  readonly dummyField: ToField<'bool'>;

  private constructor(typeArgs: [], fields: WSUIFields) {
    this.$fullTypeName = composeSuiType(WSUI.$typeName, ...typeArgs) as `${typeof PKG_V1}::wsui::WSUI`;
    this.$typeArgs = typeArgs;

    this.dummyField = fields.dummyField;
  }

  static reified(): WSUIReified {
    return {
      typeName: WSUI.$typeName,
      fullTypeName: composeSuiType(WSUI.$typeName, ...[]) as `${typeof PKG_V1}::wsui::WSUI`,
      typeArgs: [] as [],
      isPhantom: WSUI.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => WSUI.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => WSUI.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => WSUI.fromBcs(data),
      bcs: WSUI.bcs,
      fromJSONField: (field: any) => WSUI.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => WSUI.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => WSUI.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => WSUI.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => WSUI.fetch(client, id),
      new: (fields: WSUIFields) => {
        return new WSUI([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return WSUI.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<WSUI>> {
    return phantom(WSUI.reified());
  }
  static get p() {
    return WSUI.phantom();
  }

  static get bcs() {
    return bcs.struct('WSUI', {
      dummy_field: bcs.bool(),
    });
  }

  static fromFields(fields: Record<string, any>): WSUI {
    return WSUI.reified().new({ dummyField: decodeFromFields('bool', fields.dummy_field) });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): WSUI {
    if (!isWSUI(item.type)) {
      throw new Error('not a WSUI type');
    }

    return WSUI.reified().new({ dummyField: decodeFromFieldsWithTypes('bool', item.fields.dummy_field) });
  }

  static fromBcs(data: Uint8Array): WSUI {
    return WSUI.fromFields(WSUI.bcs.parse(data));
  }

  toJSONField() {
    return {
      dummyField: this.dummyField,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): WSUI {
    return WSUI.reified().new({ dummyField: decodeFromJSONField('bool', field.dummyField) });
  }

  static fromJSON(json: Record<string, any>): WSUI {
    if (json.$typeName !== WSUI.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return WSUI.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): WSUI {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isWSUI(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a WSUI object`);
    }
    return WSUI.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): WSUI {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isWSUI(data.bcs.type)) {
        throw new Error(`object at is not a WSUI object`);
      }

      return WSUI.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return WSUI.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<WSUI> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching WSUI object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isWSUI(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a WSUI object`);
    }

    return WSUI.fromSuiObjectData(res.data);
  }
}
