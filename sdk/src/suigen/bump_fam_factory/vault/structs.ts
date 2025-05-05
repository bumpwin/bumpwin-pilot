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
import {
  FieldsWithTypes,
  composeSuiType,
  compressSuiType,
  parseTypeName,
} from '../../_framework/util';
import { PKG_V1 } from '../index';
import { bcs } from '@mysten/sui/bcs';
import { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64 } from '@mysten/sui/utils';

/* ============================== BumpWinCoinVault =============================== */

export function isBumpWinCoinVault(type: string): boolean {
  type = compressSuiType(type);
  return type.startsWith(`${PKG_V1}::vault::BumpWinCoinVault` + '<');
}

export interface BumpWinCoinVaultFields<T0 extends PhantomTypeArgument> {
  id: ToField<UID>;
  reserve: ToField<Balance<T0>>;
}

export type BumpWinCoinVaultReified<T0 extends PhantomTypeArgument> = Reified<
  BumpWinCoinVault<T0>,
  BumpWinCoinVaultFields<T0>
>;

export class BumpWinCoinVault<T0 extends PhantomTypeArgument> implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::vault::BumpWinCoinVault`;
  static readonly $numTypeParams = 1;
  static readonly $isPhantom = [true] as const;

  readonly $typeName = BumpWinCoinVault.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::vault::BumpWinCoinVault<${PhantomToTypeStr<T0>}>`;
  readonly $typeArgs: [PhantomToTypeStr<T0>];
  readonly $isPhantom = BumpWinCoinVault.$isPhantom;

  readonly id: ToField<UID>;
  readonly reserve: ToField<Balance<T0>>;

  private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: BumpWinCoinVaultFields<T0>) {
    this.$fullTypeName = composeSuiType(
      BumpWinCoinVault.$typeName,
      ...typeArgs
    ) as `${typeof PKG_V1}::vault::BumpWinCoinVault<${PhantomToTypeStr<T0>}>`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
    this.reserve = fields.reserve;
  }

  static reified<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0
  ): BumpWinCoinVaultReified<ToPhantomTypeArgument<T0>> {
    return {
      typeName: BumpWinCoinVault.$typeName,
      fullTypeName: composeSuiType(
        BumpWinCoinVault.$typeName,
        ...[extractType(T0)]
      ) as `${typeof PKG_V1}::vault::BumpWinCoinVault<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`,
      typeArgs: [extractType(T0)] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>],
      isPhantom: BumpWinCoinVault.$isPhantom,
      reifiedTypeArgs: [T0],
      fromFields: (fields: Record<string, any>) => BumpWinCoinVault.fromFields(T0, fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) =>
        BumpWinCoinVault.fromFieldsWithTypes(T0, item),
      fromBcs: (data: Uint8Array) => BumpWinCoinVault.fromBcs(T0, data),
      bcs: BumpWinCoinVault.bcs,
      fromJSONField: (field: any) => BumpWinCoinVault.fromJSONField(T0, field),
      fromJSON: (json: Record<string, any>) => BumpWinCoinVault.fromJSON(T0, json),
      fromSuiParsedData: (content: SuiParsedData) =>
        BumpWinCoinVault.fromSuiParsedData(T0, content),
      fromSuiObjectData: (content: SuiObjectData) =>
        BumpWinCoinVault.fromSuiObjectData(T0, content),
      fetch: async (client: SuiClient, id: string) => BumpWinCoinVault.fetch(client, T0, id),
      new: (fields: BumpWinCoinVaultFields<ToPhantomTypeArgument<T0>>) => {
        return new BumpWinCoinVault([extractType(T0)], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return BumpWinCoinVault.reified;
  }

  static phantom<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0
  ): PhantomReified<ToTypeStr<BumpWinCoinVault<ToPhantomTypeArgument<T0>>>> {
    return phantom(BumpWinCoinVault.reified(T0));
  }
  static get p() {
    return BumpWinCoinVault.phantom;
  }

  static get bcs() {
    return bcs.struct('BumpWinCoinVault', {
      id: UID.bcs,
      reserve: Balance.bcs,
    });
  }

  static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    fields: Record<string, any>
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    return BumpWinCoinVault.reified(typeArg).new({
      id: decodeFromFields(UID.reified(), fields.id),
      reserve: decodeFromFields(Balance.reified(typeArg), fields.reserve),
    });
  }

  static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    item: FieldsWithTypes
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    if (!isBumpWinCoinVault(item.type)) {
      throw new Error('not a BumpWinCoinVault type');
    }
    assertFieldsWithTypesArgsMatch(item, [typeArg]);

    return BumpWinCoinVault.reified(typeArg).new({
      id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id),
      reserve: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.reserve),
    });
  }

  static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: Uint8Array
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    return BumpWinCoinVault.fromFields(typeArg, BumpWinCoinVault.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
      reserve: this.reserve.toJSONField(),
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    field: any
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    return BumpWinCoinVault.reified(typeArg).new({
      id: decodeFromJSONField(UID.reified(), field.id),
      reserve: decodeFromJSONField(Balance.reified(typeArg), field.reserve),
    });
  }

  static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    json: Record<string, any>
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    if (json.$typeName !== BumpWinCoinVault.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }
    assertReifiedTypeArgsMatch(
      composeSuiType(BumpWinCoinVault.$typeName, extractType(typeArg)),
      json.$typeArgs,
      [typeArg]
    );

    return BumpWinCoinVault.fromJSONField(typeArg, json);
  }

  static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    content: SuiParsedData
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isBumpWinCoinVault(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a BumpWinCoinVault object`);
    }
    return BumpWinCoinVault.fromFieldsWithTypes(typeArg, content);
  }

  static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: SuiObjectData
  ): BumpWinCoinVault<ToPhantomTypeArgument<T0>> {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isBumpWinCoinVault(data.bcs.type)) {
        throw new Error(`object at is not a BumpWinCoinVault object`);
      }

      const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs;
      if (gotTypeArgs.length !== 1) {
        throw new Error(
          `type argument mismatch: expected 1 type argument but got '${gotTypeArgs.length}'`
        );
      }
      const gotTypeArg = compressSuiType(gotTypeArgs[0]);
      const expectedTypeArg = compressSuiType(extractType(typeArg));
      if (gotTypeArg !== compressSuiType(extractType(typeArg))) {
        throw new Error(
          `type argument mismatch: expected '${expectedTypeArg}' but got '${gotTypeArg}'`
        );
      }

      return BumpWinCoinVault.fromBcs(typeArg, fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return BumpWinCoinVault.fromSuiParsedData(typeArg, data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.'
    );
  }

  static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>(
    client: SuiClient,
    typeArg: T0,
    id: string
  ): Promise<BumpWinCoinVault<ToPhantomTypeArgument<T0>>> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching BumpWinCoinVault object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isBumpWinCoinVault(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a BumpWinCoinVault object`);
    }

    return BumpWinCoinVault.fromSuiObjectData(typeArg, res.data);
  }
}

/* ============================== AdminCap =============================== */

export function isAdminCap(type: string): boolean {
  type = compressSuiType(type);
  return type.startsWith(`${PKG_V1}::vault::AdminCap` + '<');
}

export interface AdminCapFields<T0 extends PhantomTypeArgument> {
  id: ToField<UID>;
}

export type AdminCapReified<T0 extends PhantomTypeArgument> = Reified<
  AdminCap<T0>,
  AdminCapFields<T0>
>;

export class AdminCap<T0 extends PhantomTypeArgument> implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::vault::AdminCap`;
  static readonly $numTypeParams = 1;
  static readonly $isPhantom = [true] as const;

  readonly $typeName = AdminCap.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::vault::AdminCap<${PhantomToTypeStr<T0>}>`;
  readonly $typeArgs: [PhantomToTypeStr<T0>];
  readonly $isPhantom = AdminCap.$isPhantom;

  readonly id: ToField<UID>;

  private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: AdminCapFields<T0>) {
    this.$fullTypeName = composeSuiType(
      AdminCap.$typeName,
      ...typeArgs
    ) as `${typeof PKG_V1}::vault::AdminCap<${PhantomToTypeStr<T0>}>`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
  }

  static reified<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0
  ): AdminCapReified<ToPhantomTypeArgument<T0>> {
    return {
      typeName: AdminCap.$typeName,
      fullTypeName: composeSuiType(
        AdminCap.$typeName,
        ...[extractType(T0)]
      ) as `${typeof PKG_V1}::vault::AdminCap<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`,
      typeArgs: [extractType(T0)] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>],
      isPhantom: AdminCap.$isPhantom,
      reifiedTypeArgs: [T0],
      fromFields: (fields: Record<string, any>) => AdminCap.fromFields(T0, fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => AdminCap.fromFieldsWithTypes(T0, item),
      fromBcs: (data: Uint8Array) => AdminCap.fromBcs(T0, data),
      bcs: AdminCap.bcs,
      fromJSONField: (field: any) => AdminCap.fromJSONField(T0, field),
      fromJSON: (json: Record<string, any>) => AdminCap.fromJSON(T0, json),
      fromSuiParsedData: (content: SuiParsedData) => AdminCap.fromSuiParsedData(T0, content),
      fromSuiObjectData: (content: SuiObjectData) => AdminCap.fromSuiObjectData(T0, content),
      fetch: async (client: SuiClient, id: string) => AdminCap.fetch(client, T0, id),
      new: (fields: AdminCapFields<ToPhantomTypeArgument<T0>>) => {
        return new AdminCap([extractType(T0)], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return AdminCap.reified;
  }

  static phantom<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0
  ): PhantomReified<ToTypeStr<AdminCap<ToPhantomTypeArgument<T0>>>> {
    return phantom(AdminCap.reified(T0));
  }
  static get p() {
    return AdminCap.phantom;
  }

  static get bcs() {
    return bcs.struct('AdminCap', {
      id: UID.bcs,
    });
  }

  static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    fields: Record<string, any>
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    return AdminCap.reified(typeArg).new({ id: decodeFromFields(UID.reified(), fields.id) });
  }

  static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    item: FieldsWithTypes
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    if (!isAdminCap(item.type)) {
      throw new Error('not a AdminCap type');
    }
    assertFieldsWithTypesArgsMatch(item, [typeArg]);

    return AdminCap.reified(typeArg).new({
      id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id),
    });
  }

  static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: Uint8Array
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    return AdminCap.fromFields(typeArg, AdminCap.bcs.parse(data));
  }

  toJSONField() {
    return {
      id: this.id,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    field: any
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    return AdminCap.reified(typeArg).new({ id: decodeFromJSONField(UID.reified(), field.id) });
  }

  static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    json: Record<string, any>
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    if (json.$typeName !== AdminCap.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }
    assertReifiedTypeArgsMatch(
      composeSuiType(AdminCap.$typeName, extractType(typeArg)),
      json.$typeArgs,
      [typeArg]
    );

    return AdminCap.fromJSONField(typeArg, json);
  }

  static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    content: SuiParsedData
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isAdminCap(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a AdminCap object`);
    }
    return AdminCap.fromFieldsWithTypes(typeArg, content);
  }

  static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: SuiObjectData
  ): AdminCap<ToPhantomTypeArgument<T0>> {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isAdminCap(data.bcs.type)) {
        throw new Error(`object at is not a AdminCap object`);
      }

      const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs;
      if (gotTypeArgs.length !== 1) {
        throw new Error(
          `type argument mismatch: expected 1 type argument but got '${gotTypeArgs.length}'`
        );
      }
      const gotTypeArg = compressSuiType(gotTypeArgs[0]);
      const expectedTypeArg = compressSuiType(extractType(typeArg));
      if (gotTypeArg !== compressSuiType(extractType(typeArg))) {
        throw new Error(
          `type argument mismatch: expected '${expectedTypeArg}' but got '${gotTypeArg}'`
        );
      }

      return AdminCap.fromBcs(typeArg, fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return AdminCap.fromSuiParsedData(typeArg, data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.'
    );
  }

  static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>(
    client: SuiClient,
    typeArg: T0,
    id: string
  ): Promise<AdminCap<ToPhantomTypeArgument<T0>>> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching AdminCap object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isAdminCap(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a AdminCap object`);
    }

    return AdminCap.fromSuiObjectData(typeArg, res.data);
  }
}
