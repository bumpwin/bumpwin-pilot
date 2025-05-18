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

/* ============================== CYAN =============================== */

export function isCYAN(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::cyan::CYAN`;
}

export interface CYANFields {
  dummyField: ToField<'bool'>;
}

export type CYANReified = Reified<CYAN, CYANFields>;

export class CYAN implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::cyan::CYAN`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = CYAN.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::cyan::CYAN`;
  readonly $typeArgs: [];
  readonly $isPhantom = CYAN.$isPhantom;

  readonly dummyField: ToField<'bool'>;

  private constructor(typeArgs: [], fields: CYANFields) {
    this.$fullTypeName = composeSuiType(CYAN.$typeName, ...typeArgs) as `${typeof PKG_V1}::cyan::CYAN`;
    this.$typeArgs = typeArgs;

    this.dummyField = fields.dummyField;
  }

  static reified(): CYANReified {
    return {
      typeName: CYAN.$typeName,
      fullTypeName: composeSuiType(CYAN.$typeName, ...[]) as `${typeof PKG_V1}::cyan::CYAN`,
      typeArgs: [] as [],
      isPhantom: CYAN.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => CYAN.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => CYAN.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => CYAN.fromBcs(data),
      bcs: CYAN.bcs,
      fromJSONField: (field: any) => CYAN.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => CYAN.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => CYAN.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => CYAN.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => CYAN.fetch(client, id),
      new: (fields: CYANFields) => {
        return new CYAN([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return CYAN.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<CYAN>> {
    return phantom(CYAN.reified());
  }
  static get p() {
    return CYAN.phantom();
  }

  static get bcs() {
    return bcs.struct('CYAN', {
      dummy_field: bcs.bool(),
    });
  }

  static fromFields(fields: Record<string, any>): CYAN {
    return CYAN.reified().new({ dummyField: decodeFromFields('bool', fields.dummy_field) });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): CYAN {
    if (!isCYAN(item.type)) {
      throw new Error('not a CYAN type');
    }

    return CYAN.reified().new({ dummyField: decodeFromFieldsWithTypes('bool', item.fields.dummy_field) });
  }

  static fromBcs(data: Uint8Array): CYAN {
    return CYAN.fromFields(CYAN.bcs.parse(data));
  }

  toJSONField() {
    return {
      dummyField: this.dummyField,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): CYAN {
    return CYAN.reified().new({ dummyField: decodeFromJSONField('bool', field.dummyField) });
  }

  static fromJSON(json: Record<string, any>): CYAN {
    if (json.$typeName !== CYAN.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return CYAN.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): CYAN {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isCYAN(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a CYAN object`);
    }
    return CYAN.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): CYAN {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isCYAN(data.bcs.type)) {
        throw new Error(`object at is not a CYAN object`);
      }

      return CYAN.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return CYAN.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<CYAN> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching CYAN object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isCYAN(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a CYAN object`);
    }

    return CYAN.fromSuiObjectData(res.data);
  }
}
