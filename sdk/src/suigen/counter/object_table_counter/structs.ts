import * as reified from '../../_framework/reified';
import { ID, UID } from '../../_dependencies/onchain/0x2/object/structs';
import { ObjectTable } from '../../_dependencies/onchain/0x2/object_table/structs';
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
  ToTypeStr as ToPhantom,
} from '../../_framework/reified';
import { FieldsWithTypes, composeSuiType, compressSuiType } from '../../_framework/util';
import { PKG_V1 } from '../constants';
import { bcs } from '@mysten/sui/bcs';
import { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64 } from '@mysten/sui/utils';

/* ============================== Counter =============================== */

export function isCounter(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::object_table_counter::Counter`;
}

export interface CounterFields {
  id: ToField<UID>;
  value: ToField<'u64'>;
}

export type CounterReified = Reified<Counter, CounterFields>;

export class Counter implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::object_table_counter::Counter`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = Counter.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::object_table_counter::Counter`;
  readonly $typeArgs: [];
  readonly $isPhantom = Counter.$isPhantom;

  readonly id: ToField<UID>;
  readonly value: ToField<'u64'>;

  private constructor(typeArgs: [], fields: CounterFields) {
    this.$fullTypeName = composeSuiType(
      Counter.$typeName,
      ...typeArgs,
    ) as `${typeof PKG_V1}::object_table_counter::Counter`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
    this.value = fields.value;
  }

  static reified(): CounterReified {
    return {
      typeName: Counter.$typeName,
      fullTypeName: composeSuiType(Counter.$typeName, ...[]) as `${typeof PKG_V1}::object_table_counter::Counter`,
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

/* ============================== Root =============================== */

export function isRoot(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::object_table_counter::Root`;
}

export interface RootFields {
  id: ToField<UID>;
  counters: ToField<ObjectTable<ToPhantom<ID>, ToPhantom<Counter>>>;
}

export type RootReified = Reified<Root, RootFields>;

export class Root implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::object_table_counter::Root`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = Root.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::object_table_counter::Root`;
  readonly $typeArgs: [];
  readonly $isPhantom = Root.$isPhantom;

  readonly id: ToField<UID>;
  readonly counters: ToField<ObjectTable<ToPhantom<ID>, ToPhantom<Counter>>>;

  private constructor(typeArgs: [], fields: RootFields) {
    this.$fullTypeName = composeSuiType(Root.$typeName, ...typeArgs) as `${typeof PKG_V1}::object_table_counter::Root`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
    this.counters = fields.counters;
  }

  static reified(): RootReified {
    return {
      typeName: Root.$typeName,
      fullTypeName: composeSuiType(Root.$typeName, ...[]) as `${typeof PKG_V1}::object_table_counter::Root`,
      typeArgs: [] as [],
      isPhantom: Root.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => Root.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => Root.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => Root.fromBcs(data),
      bcs: Root.bcs,
      fromJSONField: (field: any) => Root.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => Root.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => Root.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => Root.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => Root.fetch(client, id),
      new: (fields: RootFields) => {
        return new Root([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return Root.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<Root>> {
    return phantom(Root.reified());
  }
  static get p() {
    return Root.phantom();
  }

  static get bcs() {
    return bcs.struct('Root', {
      id: UID.bcs,
      counters: ObjectTable.bcs,
    });
  }

  static fromFields(fields: Record<string, any>): Root {
    return Root.reified().new({
      id: decodeFromFields(UID.reified(), fields.id),
      counters: decodeFromFields(
        ObjectTable.reified(reified.phantom(ID.reified()), reified.phantom(Counter.reified())),
        fields.counters,
      ),
    });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): Root {
    if (!isRoot(item.type)) {
      throw new Error('not a Root type');
    }

    return Root.reified().new({
      id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id),
      counters: decodeFromFieldsWithTypes(
        ObjectTable.reified(reified.phantom(ID.reified()), reified.phantom(Counter.reified())),
        item.fields.counters,
      ),
    });
  }

  static fromBcs(data: Uint8Array): Root {
    return Root.fromFields(Root.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
      counters: this.counters.toJSONField(),
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): Root {
    return Root.reified().new({
      id: decodeFromJSONField(UID.reified(), field.id),
      counters: decodeFromJSONField(
        ObjectTable.reified(reified.phantom(ID.reified()), reified.phantom(Counter.reified())),
        field.counters,
      ),
    });
  }

  static fromJSON(json: Record<string, any>): Root {
    if (json.$typeName !== Root.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return Root.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): Root {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isRoot(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a Root object`);
    }
    return Root.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): Root {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isRoot(data.bcs.type)) {
        throw new Error(`object at is not a Root object`);
      }

      return Root.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return Root.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<Root> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching Root object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isRoot(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a Root object`);
    }

    return Root.fromSuiObjectData(res.data);
  }
}

/* ============================== NewCounterEvent =============================== */

export function isNewCounterEvent(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::object_table_counter::NewCounterEvent`;
}

export interface NewCounterEventFields {
  id: ToField<ID>;
}

export type NewCounterEventReified = Reified<NewCounterEvent, NewCounterEventFields>;

export class NewCounterEvent implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::object_table_counter::NewCounterEvent`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = NewCounterEvent.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::object_table_counter::NewCounterEvent`;
  readonly $typeArgs: [];
  readonly $isPhantom = NewCounterEvent.$isPhantom;

  readonly id: ToField<ID>;

  private constructor(typeArgs: [], fields: NewCounterEventFields) {
    this.$fullTypeName = composeSuiType(
      NewCounterEvent.$typeName,
      ...typeArgs,
    ) as `${typeof PKG_V1}::object_table_counter::NewCounterEvent`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
  }

  static reified(): NewCounterEventReified {
    return {
      typeName: NewCounterEvent.$typeName,
      fullTypeName: composeSuiType(
        NewCounterEvent.$typeName,
        ...[],
      ) as `${typeof PKG_V1}::object_table_counter::NewCounterEvent`,
      typeArgs: [] as [],
      isPhantom: NewCounterEvent.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => NewCounterEvent.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => NewCounterEvent.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => NewCounterEvent.fromBcs(data),
      bcs: NewCounterEvent.bcs,
      fromJSONField: (field: any) => NewCounterEvent.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => NewCounterEvent.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => NewCounterEvent.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => NewCounterEvent.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => NewCounterEvent.fetch(client, id),
      new: (fields: NewCounterEventFields) => {
        return new NewCounterEvent([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return NewCounterEvent.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<NewCounterEvent>> {
    return phantom(NewCounterEvent.reified());
  }
  static get p() {
    return NewCounterEvent.phantom();
  }

  static get bcs() {
    return bcs.struct('NewCounterEvent', {
      id: ID.bcs,
    });
  }

  static fromFields(fields: Record<string, any>): NewCounterEvent {
    return NewCounterEvent.reified().new({ id: decodeFromFields(ID.reified(), fields.id) });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): NewCounterEvent {
    if (!isNewCounterEvent(item.type)) {
      throw new Error('not a NewCounterEvent type');
    }

    return NewCounterEvent.reified().new({ id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id) });
  }

  static fromBcs(data: Uint8Array): NewCounterEvent {
    return NewCounterEvent.fromFields(NewCounterEvent.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): NewCounterEvent {
    return NewCounterEvent.reified().new({ id: decodeFromJSONField(ID.reified(), field.id) });
  }

  static fromJSON(json: Record<string, any>): NewCounterEvent {
    if (json.$typeName !== NewCounterEvent.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return NewCounterEvent.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): NewCounterEvent {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isNewCounterEvent(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a NewCounterEvent object`);
    }
    return NewCounterEvent.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): NewCounterEvent {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isNewCounterEvent(data.bcs.type)) {
        throw new Error(`object at is not a NewCounterEvent object`);
      }

      return NewCounterEvent.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return NewCounterEvent.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<NewCounterEvent> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching NewCounterEvent object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isNewCounterEvent(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a NewCounterEvent object`);
    }

    return NewCounterEvent.fromSuiObjectData(res.data);
  }
}

/* ============================== IncrementEvent =============================== */

export function isIncrementEvent(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::object_table_counter::IncrementEvent`;
}

export interface IncrementEventFields {
  id: ToField<ID>;
}

export type IncrementEventReified = Reified<IncrementEvent, IncrementEventFields>;

export class IncrementEvent implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::object_table_counter::IncrementEvent`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = IncrementEvent.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::object_table_counter::IncrementEvent`;
  readonly $typeArgs: [];
  readonly $isPhantom = IncrementEvent.$isPhantom;

  readonly id: ToField<ID>;

  private constructor(typeArgs: [], fields: IncrementEventFields) {
    this.$fullTypeName = composeSuiType(
      IncrementEvent.$typeName,
      ...typeArgs,
    ) as `${typeof PKG_V1}::object_table_counter::IncrementEvent`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
  }

  static reified(): IncrementEventReified {
    return {
      typeName: IncrementEvent.$typeName,
      fullTypeName: composeSuiType(
        IncrementEvent.$typeName,
        ...[],
      ) as `${typeof PKG_V1}::object_table_counter::IncrementEvent`,
      typeArgs: [] as [],
      isPhantom: IncrementEvent.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => IncrementEvent.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => IncrementEvent.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => IncrementEvent.fromBcs(data),
      bcs: IncrementEvent.bcs,
      fromJSONField: (field: any) => IncrementEvent.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => IncrementEvent.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => IncrementEvent.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => IncrementEvent.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => IncrementEvent.fetch(client, id),
      new: (fields: IncrementEventFields) => {
        return new IncrementEvent([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return IncrementEvent.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<IncrementEvent>> {
    return phantom(IncrementEvent.reified());
  }
  static get p() {
    return IncrementEvent.phantom();
  }

  static get bcs() {
    return bcs.struct('IncrementEvent', {
      id: ID.bcs,
    });
  }

  static fromFields(fields: Record<string, any>): IncrementEvent {
    return IncrementEvent.reified().new({ id: decodeFromFields(ID.reified(), fields.id) });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): IncrementEvent {
    if (!isIncrementEvent(item.type)) {
      throw new Error('not a IncrementEvent type');
    }

    return IncrementEvent.reified().new({ id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id) });
  }

  static fromBcs(data: Uint8Array): IncrementEvent {
    return IncrementEvent.fromFields(IncrementEvent.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): IncrementEvent {
    return IncrementEvent.reified().new({ id: decodeFromJSONField(ID.reified(), field.id) });
  }

  static fromJSON(json: Record<string, any>): IncrementEvent {
    if (json.$typeName !== IncrementEvent.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return IncrementEvent.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): IncrementEvent {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isIncrementEvent(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a IncrementEvent object`);
    }
    return IncrementEvent.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): IncrementEvent {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isIncrementEvent(data.bcs.type)) {
        throw new Error(`object at is not a IncrementEvent object`);
      }

      return IncrementEvent.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return IncrementEvent.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<IncrementEvent> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching IncrementEvent object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isIncrementEvent(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a IncrementEvent object`);
    }

    return IncrementEvent.fromSuiObjectData(res.data);
  }
}
