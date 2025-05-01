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

/* ============================== OozeFamVault =============================== */

export function isOozeFamVault(type: string): boolean {
  type = compressSuiType(type);
  return type.startsWith(`${PKG_V1}::ooze_fam_factory::OozeFamVault` + '<');
}

export interface OozeFamVaultFields<T0 extends PhantomTypeArgument> {
  id: ToField<UID>;
  reserve: ToField<Balance<T0>>;
}

export type OozeFamVaultReified<T0 extends PhantomTypeArgument> = Reified<
  OozeFamVault<T0>,
  OozeFamVaultFields<T0>
>;

export class OozeFamVault<T0 extends PhantomTypeArgument> implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::ooze_fam_factory::OozeFamVault`;
  static readonly $numTypeParams = 1;
  static readonly $isPhantom = [true] as const;

  readonly $typeName = OozeFamVault.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::ooze_fam_factory::OozeFamVault<${PhantomToTypeStr<T0>}>`;
  readonly $typeArgs: [PhantomToTypeStr<T0>];
  readonly $isPhantom = OozeFamVault.$isPhantom;

  readonly id: ToField<UID>;
  readonly reserve: ToField<Balance<T0>>;

  private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: OozeFamVaultFields<T0>) {
    this.$fullTypeName = composeSuiType(
      OozeFamVault.$typeName,
      ...typeArgs
    ) as `${typeof PKG_V1}::ooze_fam_factory::OozeFamVault<${PhantomToTypeStr<T0>}>`;
    this.$typeArgs = typeArgs;

    this.id = fields.id;
    this.reserve = fields.reserve;
  }

  static reified<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0
  ): OozeFamVaultReified<ToPhantomTypeArgument<T0>> {
    return {
      typeName: OozeFamVault.$typeName,
      fullTypeName: composeSuiType(
        OozeFamVault.$typeName,
        ...[extractType(T0)]
      ) as `${typeof PKG_V1}::ooze_fam_factory::OozeFamVault<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`,
      typeArgs: [extractType(T0)] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>],
      isPhantom: OozeFamVault.$isPhantom,
      reifiedTypeArgs: [T0],
      fromFields: (fields: Record<string, any>) => OozeFamVault.fromFields(T0, fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => OozeFamVault.fromFieldsWithTypes(T0, item),
      fromBcs: (data: Uint8Array) => OozeFamVault.fromBcs(T0, data),
      bcs: OozeFamVault.bcs,
      fromJSONField: (field: any) => OozeFamVault.fromJSONField(T0, field),
      fromJSON: (json: Record<string, any>) => OozeFamVault.fromJSON(T0, json),
      fromSuiParsedData: (content: SuiParsedData) => OozeFamVault.fromSuiParsedData(T0, content),
      fromSuiObjectData: (content: SuiObjectData) => OozeFamVault.fromSuiObjectData(T0, content),
      fetch: async (client: SuiClient, id: string) => OozeFamVault.fetch(client, T0, id),
      new: (fields: OozeFamVaultFields<ToPhantomTypeArgument<T0>>) => {
        return new OozeFamVault([extractType(T0)], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return OozeFamVault.reified;
  }

  static phantom<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0
  ): PhantomReified<ToTypeStr<OozeFamVault<ToPhantomTypeArgument<T0>>>> {
    return phantom(OozeFamVault.reified(T0));
  }
  static get p() {
    return OozeFamVault.phantom;
  }

  static get bcs() {
    return bcs.struct('OozeFamVault', {
      id: UID.bcs,
      reserve: Balance.bcs,
    });
  }

  static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    fields: Record<string, any>
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    return OozeFamVault.reified(typeArg).new({
      id: decodeFromFields(UID.reified(), fields.id),
      reserve: decodeFromFields(Balance.reified(typeArg), fields.reserve),
    });
  }

  static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    item: FieldsWithTypes
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    if (!isOozeFamVault(item.type)) {
      throw new Error('not a OozeFamVault type');
    }
    assertFieldsWithTypesArgsMatch(item, [typeArg]);

    return OozeFamVault.reified(typeArg).new({
      id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id),
      reserve: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.reserve),
    });
  }

  static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: Uint8Array
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    return OozeFamVault.fromFields(typeArg, OozeFamVault.bcs.parse(data));
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
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    return OozeFamVault.reified(typeArg).new({
      id: decodeFromJSONField(UID.reified(), field.id),
      reserve: decodeFromJSONField(Balance.reified(typeArg), field.reserve),
    });
  }

  static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    json: Record<string, any>
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    if (json.$typeName !== OozeFamVault.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }
    assertReifiedTypeArgsMatch(
      composeSuiType(OozeFamVault.$typeName, extractType(typeArg)),
      json.$typeArgs,
      [typeArg]
    );

    return OozeFamVault.fromJSONField(typeArg, json);
  }

  static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    content: SuiParsedData
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isOozeFamVault(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a OozeFamVault object`);
    }
    return OozeFamVault.fromFieldsWithTypes(typeArg, content);
  }

  static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: SuiObjectData
  ): OozeFamVault<ToPhantomTypeArgument<T0>> {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isOozeFamVault(data.bcs.type)) {
        throw new Error(`object at is not a OozeFamVault object`);
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

      return OozeFamVault.fromBcs(typeArg, fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return OozeFamVault.fromSuiParsedData(typeArg, data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.'
    );
  }

  static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>(
    client: SuiClient,
    typeArg: T0,
    id: string
  ): Promise<OozeFamVault<ToPhantomTypeArgument<T0>>> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching OozeFamVault object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isOozeFamVault(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a OozeFamVault object`);
    }

    return OozeFamVault.fromSuiObjectData(typeArg, res.data);
  }
}
