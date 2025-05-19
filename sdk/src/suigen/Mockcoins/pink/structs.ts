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

/* ============================== PINK =============================== */

export function isPINK(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::pink::PINK`;
}

export interface PINKFields {
  dummyField: ToField<'bool'>;
}

export type PINKReified = Reified<PINK, PINKFields>;

export class PINK implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::pink::PINK`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = PINK.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::pink::PINK`;
  readonly $typeArgs: [];
  readonly $isPhantom = PINK.$isPhantom;

  readonly dummyField: ToField<'bool'>;

  private constructor(typeArgs: [], fields: PINKFields) {
    this.$fullTypeName = composeSuiType(PINK.$typeName, ...typeArgs) as `${typeof PKG_V1}::pink::PINK`;
    this.$typeArgs = typeArgs;

    this.dummyField = fields.dummyField;
  }

  static reified(): PINKReified {
    return {
      typeName: PINK.$typeName,
      fullTypeName: composeSuiType(PINK.$typeName, ...[]) as `${typeof PKG_V1}::pink::PINK`,
      typeArgs: [] as [],
      isPhantom: PINK.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => PINK.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => PINK.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => PINK.fromBcs(data),
      bcs: PINK.bcs,
      fromJSONField: (field: any) => PINK.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => PINK.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => PINK.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => PINK.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => PINK.fetch(client, id),
      new: (fields: PINKFields) => {
        return new PINK([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return PINK.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<PINK>> {
    return phantom(PINK.reified());
  }
  static get p() {
    return PINK.phantom();
  }

  static get bcs() {
    return bcs.struct('PINK', {
      dummy_field: bcs.bool(),
    });
  }

  static fromFields(fields: Record<string, any>): PINK {
    return PINK.reified().new({ dummyField: decodeFromFields('bool', fields.dummy_field) });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): PINK {
    if (!isPINK(item.type)) {
      throw new Error('not a PINK type');
    }

    return PINK.reified().new({ dummyField: decodeFromFieldsWithTypes('bool', item.fields.dummy_field) });
  }

  static fromBcs(data: Uint8Array): PINK {
    return PINK.fromFields(PINK.bcs.parse(data));
  }

  toJSONField() {
    return {
      dummyField: this.dummyField,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): PINK {
    return PINK.reified().new({ dummyField: decodeFromJSONField('bool', field.dummyField) });
  }

  static fromJSON(json: Record<string, any>): PINK {
    if (json.$typeName !== PINK.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return PINK.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): PINK {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isPINK(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a PINK object`);
    }
    return PINK.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): PINK {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isPINK(data.bcs.type)) {
        throw new Error(`object at is not a PINK object`);
      }

      return PINK.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return PINK.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<PINK> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching PINK object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isPINK(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a PINK object`);
    }

    return PINK.fromSuiObjectData(res.data);
  }
}
