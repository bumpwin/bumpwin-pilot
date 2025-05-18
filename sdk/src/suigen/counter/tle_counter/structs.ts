import { UID } from '../../_dependencies/onchain/0x2/object/structs';
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

/* ============================== Counter =============================== */

export function isCounter(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::tle_counter::Counter`;
}

export interface CounterFields {
  id: ToField<UID>;
  value: ToField<'u64'>;
}

export type CounterReified = Reified<Counter, CounterFields>;

export class Counter implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::tle_counter::Counter`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = Counter.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::tle_counter::Counter`;
  readonly $typeArgs: [];
  readonly $isPhantom = Counter.$isPhantom;

  readonly id: ToField<UID>;
  readonly value: ToField<'u64'>;

  private constructor(typeArgs: [], fields: CounterFields) {
    this.$fullTypeName = composeSuiType(Counter.$typeName, ...typeArgs) as `${typeof PKG_V1}::tle_counter::Counter`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
    this.value = fields.value;
  }

  static reified(): CounterReified {
    return {
      typeName: Counter.$typeName,
      fullTypeName: composeSuiType(Counter.$typeName, ...[]) as `${typeof PKG_V1}::tle_counter::Counter`,
      typeArgs: [] as [],
      isPhantom: Counter.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => Counter.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => Counter.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => Counter.fromBcs(data),
      bcs: Counter.bcs,
      fromJSONField: (field: any) => Counter.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => Counter.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => Counter.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => Counter.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => Counter.fetch(client, id),
      new: (fields: CounterFields) => {
        return new Counter([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return Counter.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<Counter>> {
    return phantom(Counter.reified());
  }
  static get p() {
    return Counter.phantom();
  }

  static get bcs() {
    return bcs.struct('Counter', {
      id: UID.bcs,
      value: bcs.u64(),
    });
  }

  static fromFields(fields: Record<string, any>): Counter {
    return Counter.reified().new({
      id: decodeFromFields(UID.reified(), fields.id),
      value: decodeFromFields('u64', fields.value),
    });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): Counter {
    if (!isCounter(item.type)) {
      throw new Error('not a Counter type');
    }

    return Counter.reified().new({
      id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id),
      value: decodeFromFieldsWithTypes('u64', item.fields.value),
    });
  }

  static fromBcs(data: Uint8Array): Counter {
    return Counter.fromFields(Counter.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
      value: this.value.toString(),
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): Counter {
    return Counter.reified().new({
      id: decodeFromJSONField(UID.reified(), field.id),
      value: decodeFromJSONField('u64', field.value),
    });
  }

  static fromJSON(json: Record<string, any>): Counter {
    if (json.$typeName !== Counter.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return Counter.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): Counter {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isCounter(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a Counter object`);
    }
    return Counter.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): Counter {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isCounter(data.bcs.type)) {
        throw new Error(`object at is not a Counter object`);
      }

      return Counter.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return Counter.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<Counter> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching Counter object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isCounter(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a Counter object`);
    }

    return Counter.fromSuiObjectData(res.data);
  }
}
