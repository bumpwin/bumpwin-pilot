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
import { PKG_V1 } from '../index';
import { bcs } from '@mysten/sui/bcs';
import { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64 } from '@mysten/sui/utils';

/* ============================== BLACK =============================== */

export function isBLACK(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::black::BLACK`;
}

export interface BLACKFields {
  dummyField: ToField<'bool'>;
}

export type BLACKReified = Reified<BLACK, BLACKFields>;

export class BLACK implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::black::BLACK`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = BLACK.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::black::BLACK`;
  readonly $typeArgs: [];
  readonly $isPhantom = BLACK.$isPhantom;

  readonly dummyField: ToField<'bool'>;

  private constructor(typeArgs: [], fields: BLACKFields) {
    this.$fullTypeName = composeSuiType(BLACK.$typeName, ...typeArgs) as `${typeof PKG_V1}::black::BLACK`;
    this.$typeArgs = typeArgs;

    this.dummyField = fields.dummyField;
  }

  static reified(): BLACKReified {
    return {
      typeName: BLACK.$typeName,
      fullTypeName: composeSuiType(BLACK.$typeName, ...[]) as `${typeof PKG_V1}::black::BLACK`,
      typeArgs: [] as [],
      isPhantom: BLACK.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => BLACK.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => BLACK.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => BLACK.fromBcs(data),
      bcs: BLACK.bcs,
      fromJSONField: (field: any) => BLACK.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => BLACK.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => BLACK.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => BLACK.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => BLACK.fetch(client, id),
      new: (fields: BLACKFields) => {
        return new BLACK([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return BLACK.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<BLACK>> {
    return phantom(BLACK.reified());
  }
  static get p() {
    return BLACK.phantom();
  }

  static get bcs() {
    return bcs.struct('BLACK', {
      dummy_field: bcs.bool(),
    });
  }

  static fromFields(fields: Record<string, any>): BLACK {
    return BLACK.reified().new({ dummyField: decodeFromFields('bool', fields.dummy_field) });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): BLACK {
    if (!isBLACK(item.type)) {
      throw new Error('not a BLACK type');
    }

    return BLACK.reified().new({ dummyField: decodeFromFieldsWithTypes('bool', item.fields.dummy_field) });
  }

  static fromBcs(data: Uint8Array): BLACK {
    return BLACK.fromFields(BLACK.bcs.parse(data));
  }

  toJSONField() {
    return {
      dummyField: this.dummyField,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): BLACK {
    return BLACK.reified().new({ dummyField: decodeFromJSONField('bool', field.dummyField) });
  }

  static fromJSON(json: Record<string, any>): BLACK {
    if (json.$typeName !== BLACK.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return BLACK.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): BLACK {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isBLACK(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a BLACK object`);
    }
    return BLACK.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): BLACK {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isBLACK(data.bcs.type)) {
        throw new Error(`object at is not a BLACK object`);
      }

      return BLACK.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return BLACK.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<BLACK> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching BLACK object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isBLACK(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a BLACK object`);
    }

    return BLACK.fromSuiObjectData(res.data);
  }
}
