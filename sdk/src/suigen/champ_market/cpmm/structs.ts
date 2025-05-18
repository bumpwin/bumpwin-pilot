import { Balance } from '../../_dependencies/onchain/0x2/balance/structs';
import { UID } from '../../_dependencies/onchain/0x2/object/structs';
import {
  PhantomReified,
  PhantomToTypeStr,
  PhantomTypeArgument,
  Reified,
  StructClass,
  ToField,
  ToPhantomTypeArgument,
  ToTypeStr,
  assertFieldsWithTypesArgsMatch,
  assertReifiedTypeArgsMatch,
  decodeFromFields,
  decodeFromFieldsWithTypes,
  decodeFromJSONField,
  extractType,
  phantom,
} from '../../_framework/reified';
import { FieldsWithTypes, composeSuiType, compressSuiType, parseTypeName } from '../../_framework/util';
import { PKG_V1 } from '../constants';
import { bcs } from '@mysten/sui/bcs';
import { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64, fromHEX, toHEX } from '@mysten/sui/utils';

/* ============================== Pool =============================== */

export function isPool(type: string): boolean {
  type = compressSuiType(type);
  return type.startsWith(`${PKG_V1}::cpmm::Pool` + '<');
}

export interface PoolFields<T0 extends PhantomTypeArgument, T1 extends PhantomTypeArgument> {
  id: ToField<UID>;
  reserveX: ToField<Balance<T0>>;
  reserveY: ToField<Balance<T1>>;
}

export type PoolReified<T0 extends PhantomTypeArgument, T1 extends PhantomTypeArgument> = Reified<
  Pool<T0, T1>,
  PoolFields<T0, T1>
>;

export class Pool<T0 extends PhantomTypeArgument, T1 extends PhantomTypeArgument> implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::cpmm::Pool`;
  static readonly $numTypeParams = 2;
  static readonly $isPhantom = [true, true] as const;

  readonly $typeName = Pool.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::cpmm::Pool<${PhantomToTypeStr<T0>}, ${PhantomToTypeStr<T1>}>`;
  readonly $typeArgs: [PhantomToTypeStr<T0>, PhantomToTypeStr<T1>];
  readonly $isPhantom = Pool.$isPhantom;

  readonly id: ToField<UID>;
  readonly reserveX: ToField<Balance<T0>>;
  readonly reserveY: ToField<Balance<T1>>;

  private constructor(typeArgs: [PhantomToTypeStr<T0>, PhantomToTypeStr<T1>], fields: PoolFields<T0, T1>) {
    this.$fullTypeName = composeSuiType(
      Pool.$typeName,
      ...typeArgs,
    ) as `${typeof PKG_V1}::cpmm::Pool<${PhantomToTypeStr<T0>}, ${PhantomToTypeStr<T1>}>`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
    this.reserveX = fields.reserveX;
    this.reserveY = fields.reserveY;
  }

  static reified<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0,
    T1: T1,
  ): PoolReified<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    return {
      typeName: Pool.$typeName,
      fullTypeName: composeSuiType(
        Pool.$typeName,
        ...[extractType(T0), extractType(T1)],
      ) as `${typeof PKG_V1}::cpmm::Pool<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<T1>>}>`,
      typeArgs: [extractType(T0), extractType(T1)] as [
        PhantomToTypeStr<ToPhantomTypeArgument<T0>>,
        PhantomToTypeStr<ToPhantomTypeArgument<T1>>,
      ],
      isPhantom: Pool.$isPhantom,
      reifiedTypeArgs: [T0, T1],
      fromFields: (fields: Record<string, any>) => Pool.fromFields([T0, T1], fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => Pool.fromFieldsWithTypes([T0, T1], item),
      fromBcs: (data: Uint8Array) => Pool.fromBcs([T0, T1], data),
      bcs: Pool.bcs,
      fromJSONField: (field: any) => Pool.fromJSONField([T0, T1], field),
      fromJSON: (json: Record<string, any>) => Pool.fromJSON([T0, T1], json),
      fromSuiParsedData: (content: SuiParsedData) => Pool.fromSuiParsedData([T0, T1], content),
      fromSuiObjectData: (content: SuiObjectData) => Pool.fromSuiObjectData([T0, T1], content),
      fetch: async (client: SuiClient, id: string) => Pool.fetch(client, [T0, T1], id),
      new: (fields: PoolFields<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>>) => {
        return new Pool([extractType(T0), extractType(T1)], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return Pool.reified;
  }

  static phantom<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0,
    T1: T1,
  ): PhantomReified<ToTypeStr<Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>>>> {
    return phantom(Pool.reified(T0, T1));
  }
  static get p() {
    return Pool.phantom;
  }

  static get bcs() {
    return bcs.struct('Pool', {
      id: UID.bcs,
      reserve_x: Balance.bcs,
      reserve_y: Balance.bcs,
    });
  }

  static fromFields<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    typeArgs: [T0, T1],
    fields: Record<string, any>,
  ): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    return Pool.reified(typeArgs[0], typeArgs[1]).new({
      id: decodeFromFields(UID.reified(), fields.id),
      reserveX: decodeFromFields(Balance.reified(typeArgs[0]), fields.reserve_x),
      reserveY: decodeFromFields(Balance.reified(typeArgs[1]), fields.reserve_y),
    });
  }

  static fromFieldsWithTypes<
    T0 extends PhantomReified<PhantomTypeArgument>,
    T1 extends PhantomReified<PhantomTypeArgument>,
  >(typeArgs: [T0, T1], item: FieldsWithTypes): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    if (!isPool(item.type)) {
      throw new Error('not a Pool type');
    }
    assertFieldsWithTypesArgsMatch(item, typeArgs);

    return Pool.reified(typeArgs[0], typeArgs[1]).new({
      id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id),
      reserveX: decodeFromFieldsWithTypes(Balance.reified(typeArgs[0]), item.fields.reserve_x),
      reserveY: decodeFromFieldsWithTypes(Balance.reified(typeArgs[1]), item.fields.reserve_y),
    });
  }

  static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    typeArgs: [T0, T1],
    data: Uint8Array,
  ): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    return Pool.fromFields(typeArgs, Pool.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
      reserveX: this.reserveX.toJSONField(),
      reserveY: this.reserveY.toJSONField(),
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    typeArgs: [T0, T1],
    field: any,
  ): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    return Pool.reified(typeArgs[0], typeArgs[1]).new({
      id: decodeFromJSONField(UID.reified(), field.id),
      reserveX: decodeFromJSONField(Balance.reified(typeArgs[0]), field.reserveX),
      reserveY: decodeFromJSONField(Balance.reified(typeArgs[1]), field.reserveY),
    });
  }

  static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    typeArgs: [T0, T1],
    json: Record<string, any>,
  ): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    if (json.$typeName !== Pool.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }
    assertReifiedTypeArgsMatch(composeSuiType(Pool.$typeName, ...typeArgs.map(extractType)), json.$typeArgs, typeArgs);

    return Pool.fromJSONField(typeArgs, json);
  }

  static fromSuiParsedData<
    T0 extends PhantomReified<PhantomTypeArgument>,
    T1 extends PhantomReified<PhantomTypeArgument>,
  >(typeArgs: [T0, T1], content: SuiParsedData): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isPool(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a Pool object`);
    }
    return Pool.fromFieldsWithTypes(typeArgs, content);
  }

  static fromSuiObjectData<
    T0 extends PhantomReified<PhantomTypeArgument>,
    T1 extends PhantomReified<PhantomTypeArgument>,
  >(typeArgs: [T0, T1], data: SuiObjectData): Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>> {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isPool(data.bcs.type)) {
        throw new Error(`object at is not a Pool object`);
      }

      const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs;
      if (gotTypeArgs.length !== 2) {
        throw new Error(`type argument mismatch: expected 2 type arguments but got ${gotTypeArgs.length}`);
      }
      for (let i = 0; i < 2; i++) {
        const gotTypeArg = compressSuiType(gotTypeArgs[i]);
        const expectedTypeArg = compressSuiType(extractType(typeArgs[i]));
        if (gotTypeArg !== expectedTypeArg) {
          throw new Error(
            `type argument mismatch at position ${i}: expected '${expectedTypeArg}' but got '${gotTypeArg}'`,
          );
        }
      }

      return Pool.fromBcs(typeArgs, fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return Pool.fromSuiParsedData(typeArgs, data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch<T0 extends PhantomReified<PhantomTypeArgument>, T1 extends PhantomReified<PhantomTypeArgument>>(
    client: SuiClient,
    typeArgs: [T0, T1],
    id: string,
  ): Promise<Pool<ToPhantomTypeArgument<T0>, ToPhantomTypeArgument<T1>>> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching Pool object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isPool(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a Pool object`);
    }

    return Pool.fromSuiObjectData(typeArgs, res.data);
  }
}

/* ============================== SwapEvent =============================== */

export function isSwapEvent(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::cpmm::SwapEvent`;
}

export interface SwapEventFields {
  sender: ToField<'address'>;
  isXToY: ToField<'bool'>;
  amountIn: ToField<'u64'>;
  amountOut: ToField<'u64'>;
}

export type SwapEventReified = Reified<SwapEvent, SwapEventFields>;

export class SwapEvent implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::cpmm::SwapEvent`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = SwapEvent.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::cpmm::SwapEvent`;
  readonly $typeArgs: [];
  readonly $isPhantom = SwapEvent.$isPhantom;

  readonly sender: ToField<'address'>;
  readonly isXToY: ToField<'bool'>;
  readonly amountIn: ToField<'u64'>;
  readonly amountOut: ToField<'u64'>;

  private constructor(typeArgs: [], fields: SwapEventFields) {
    this.$fullTypeName = composeSuiType(SwapEvent.$typeName, ...typeArgs) as `${typeof PKG_V1}::cpmm::SwapEvent`;
    this.$typeArgs = typeArgs;

    this.sender = fields.sender;
    this.isXToY = fields.isXToY;
    this.amountIn = fields.amountIn;
    this.amountOut = fields.amountOut;
  }

  static reified(): SwapEventReified {
    return {
      typeName: SwapEvent.$typeName,
      fullTypeName: composeSuiType(SwapEvent.$typeName, ...[]) as `${typeof PKG_V1}::cpmm::SwapEvent`,
      typeArgs: [] as [],
      isPhantom: SwapEvent.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => SwapEvent.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => SwapEvent.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => SwapEvent.fromBcs(data),
      bcs: SwapEvent.bcs,
      fromJSONField: (field: any) => SwapEvent.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => SwapEvent.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) => SwapEvent.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) => SwapEvent.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => SwapEvent.fetch(client, id),
      new: (fields: SwapEventFields) => {
        return new SwapEvent([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return SwapEvent.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<SwapEvent>> {
    return phantom(SwapEvent.reified());
  }
  static get p() {
    return SwapEvent.phantom();
  }

  static get bcs() {
    return bcs.struct('SwapEvent', {
      sender: bcs
        .bytes(32)
        .transform({ input: (val: string) => fromHEX(val), output: (val: Uint8Array) => toHEX(val) }),
      is_x_to_y: bcs.bool(),
      amount_in: bcs.u64(),
      amount_out: bcs.u64(),
    });
  }

  static fromFields(fields: Record<string, any>): SwapEvent {
    return SwapEvent.reified().new({
      sender: decodeFromFields('address', fields.sender),
      isXToY: decodeFromFields('bool', fields.is_x_to_y),
      amountIn: decodeFromFields('u64', fields.amount_in),
      amountOut: decodeFromFields('u64', fields.amount_out),
    });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): SwapEvent {
    if (!isSwapEvent(item.type)) {
      throw new Error('not a SwapEvent type');
    }

    return SwapEvent.reified().new({
      sender: decodeFromFieldsWithTypes('address', item.fields.sender),
      isXToY: decodeFromFieldsWithTypes('bool', item.fields.is_x_to_y),
      amountIn: decodeFromFieldsWithTypes('u64', item.fields.amount_in),
      amountOut: decodeFromFieldsWithTypes('u64', item.fields.amount_out),
    });
  }

  static fromBcs(data: Uint8Array): SwapEvent {
    return SwapEvent.fromFields(SwapEvent.bcs.parse(data));
  }

  toJSONField() {
    return {
      sender: this.sender,
      isXToY: this.isXToY,
      amountIn: this.amountIn.toString(),
      amountOut: this.amountOut.toString(),
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): SwapEvent {
    return SwapEvent.reified().new({
      sender: decodeFromJSONField('address', field.sender),
      isXToY: decodeFromJSONField('bool', field.isXToY),
      amountIn: decodeFromJSONField('u64', field.amountIn),
      amountOut: decodeFromJSONField('u64', field.amountOut),
    });
  }

  static fromJSON(json: Record<string, any>): SwapEvent {
    if (json.$typeName !== SwapEvent.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return SwapEvent.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): SwapEvent {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isSwapEvent(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a SwapEvent object`);
    }
    return SwapEvent.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): SwapEvent {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isSwapEvent(data.bcs.type)) {
        throw new Error(`object at is not a SwapEvent object`);
      }

      return SwapEvent.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return SwapEvent.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<SwapEvent> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching SwapEvent object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isSwapEvent(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a SwapEvent object`);
    }

    return SwapEvent.fromSuiObjectData(res.data);
  }
}
