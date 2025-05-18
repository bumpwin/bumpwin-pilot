import { String as String1 } from '../../_dependencies/onchain/0x1/ascii/structs';
import { String } from '../../_dependencies/onchain/0x1/string/structs';
import { Url } from '../../_dependencies/onchain/0x2/url/structs';
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
import { PKG_V1 } from '../index';
import { bcs } from '@mysten/sui/bcs';
import { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64 } from '@mysten/sui/utils';

/* ============================== CreateCoinEvent =============================== */

export function isCreateCoinEvent(type: string): boolean {
  type = compressSuiType(type);
  return type.startsWith(`${PKG_V1}::bump_fam_factory::CreateCoinEvent` + '<');
}

export interface CreateCoinEventFields<T0 extends PhantomTypeArgument> {
  name: ToField<String>;
  symbol: ToField<String1>;
  description: ToField<String>;
  iconUrl: ToField<Url>;
}

export type CreateCoinEventReified<T0 extends PhantomTypeArgument> = Reified<
  CreateCoinEvent<T0>,
  CreateCoinEventFields<T0>
>;

export class CreateCoinEvent<T0 extends PhantomTypeArgument> implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::bump_fam_factory::CreateCoinEvent`;
  static readonly $numTypeParams = 1;
  static readonly $isPhantom = [true] as const;

  readonly $typeName = CreateCoinEvent.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::bump_fam_factory::CreateCoinEvent<${PhantomToTypeStr<T0>}>`;
  readonly $typeArgs: [PhantomToTypeStr<T0>];
  readonly $isPhantom = CreateCoinEvent.$isPhantom;

  readonly name: ToField<String>;
  readonly symbol: ToField<String1>;
  readonly description: ToField<String>;
  readonly iconUrl: ToField<Url>;

  private constructor(typeArgs: [PhantomToTypeStr<T0>], fields: CreateCoinEventFields<T0>) {
    this.$fullTypeName = composeSuiType(
      CreateCoinEvent.$typeName,
      ...typeArgs,
    ) as `${typeof PKG_V1}::bump_fam_factory::CreateCoinEvent<${PhantomToTypeStr<T0>}>`;
    this.$typeArgs = typeArgs;

    this.name = fields.name;
    this.symbol = fields.symbol;
    this.description = fields.description;
    this.iconUrl = fields.iconUrl;
  }

  static reified<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0,
  ): CreateCoinEventReified<ToPhantomTypeArgument<T0>> {
    return {
      typeName: CreateCoinEvent.$typeName,
      fullTypeName: composeSuiType(
        CreateCoinEvent.$typeName,
        ...[extractType(T0)],
      ) as `${typeof PKG_V1}::bump_fam_factory::CreateCoinEvent<${PhantomToTypeStr<ToPhantomTypeArgument<T0>>}>`,
      typeArgs: [extractType(T0)] as [PhantomToTypeStr<ToPhantomTypeArgument<T0>>],
      isPhantom: CreateCoinEvent.$isPhantom,
      reifiedTypeArgs: [T0],
      fromFields: (fields: Record<string, any>) => CreateCoinEvent.fromFields(T0, fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) => CreateCoinEvent.fromFieldsWithTypes(T0, item),
      fromBcs: (data: Uint8Array) => CreateCoinEvent.fromBcs(T0, data),
      bcs: CreateCoinEvent.bcs,
      fromJSONField: (field: any) => CreateCoinEvent.fromJSONField(T0, field),
      fromJSON: (json: Record<string, any>) => CreateCoinEvent.fromJSON(T0, json),
      fromSuiParsedData: (content: SuiParsedData) => CreateCoinEvent.fromSuiParsedData(T0, content),
      fromSuiObjectData: (content: SuiObjectData) => CreateCoinEvent.fromSuiObjectData(T0, content),
      fetch: async (client: SuiClient, id: string) => CreateCoinEvent.fetch(client, T0, id),
      new: (fields: CreateCoinEventFields<ToPhantomTypeArgument<T0>>) => {
        return new CreateCoinEvent([extractType(T0)], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return CreateCoinEvent.reified;
  }

  static phantom<T0 extends PhantomReified<PhantomTypeArgument>>(
    T0: T0,
  ): PhantomReified<ToTypeStr<CreateCoinEvent<ToPhantomTypeArgument<T0>>>> {
    return phantom(CreateCoinEvent.reified(T0));
  }
  static get p() {
    return CreateCoinEvent.phantom;
  }

  static get bcs() {
    return bcs.struct('CreateCoinEvent', {
      name: String.bcs,
      symbol: String1.bcs,
      description: String.bcs,
      icon_url: Url.bcs,
    });
  }

  static fromFields<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    fields: Record<string, any>,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    return CreateCoinEvent.reified(typeArg).new({
      name: decodeFromFields(String.reified(), fields.name),
      symbol: decodeFromFields(String1.reified(), fields.symbol),
      description: decodeFromFields(String.reified(), fields.description),
      iconUrl: decodeFromFields(Url.reified(), fields.icon_url),
    });
  }

  static fromFieldsWithTypes<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    item: FieldsWithTypes,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    if (!isCreateCoinEvent(item.type)) {
      throw new Error('not a CreateCoinEvent type');
    }
    assertFieldsWithTypesArgsMatch(item, [typeArg]);

    return CreateCoinEvent.reified(typeArg).new({
      name: decodeFromFieldsWithTypes(String.reified(), item.fields.name),
      symbol: decodeFromFieldsWithTypes(String1.reified(), item.fields.symbol),
      description: decodeFromFieldsWithTypes(String.reified(), item.fields.description),
      iconUrl: decodeFromFieldsWithTypes(Url.reified(), item.fields.icon_url),
    });
  }

  static fromBcs<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: Uint8Array,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    return CreateCoinEvent.fromFields(typeArg, CreateCoinEvent.bcs.parse(data));
  }

  toJSONField() {
    return {
      name: this.name,
      symbol: this.symbol,
      description: this.description,
      iconUrl: this.iconUrl,
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    field: any,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    return CreateCoinEvent.reified(typeArg).new({
      name: decodeFromJSONField(String.reified(), field.name),
      symbol: decodeFromJSONField(String1.reified(), field.symbol),
      description: decodeFromJSONField(String.reified(), field.description),
      iconUrl: decodeFromJSONField(Url.reified(), field.iconUrl),
    });
  }

  static fromJSON<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    json: Record<string, any>,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    if (json.$typeName !== CreateCoinEvent.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }
    assertReifiedTypeArgsMatch(composeSuiType(CreateCoinEvent.$typeName, extractType(typeArg)), json.$typeArgs, [
      typeArg,
    ]);

    return CreateCoinEvent.fromJSONField(typeArg, json);
  }

  static fromSuiParsedData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    content: SuiParsedData,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isCreateCoinEvent(content.type)) {
      throw new Error(`object at ${(content.fields as any).id} is not a CreateCoinEvent object`);
    }
    return CreateCoinEvent.fromFieldsWithTypes(typeArg, content);
  }

  static fromSuiObjectData<T0 extends PhantomReified<PhantomTypeArgument>>(
    typeArg: T0,
    data: SuiObjectData,
  ): CreateCoinEvent<ToPhantomTypeArgument<T0>> {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isCreateCoinEvent(data.bcs.type)) {
        throw new Error(`object at is not a CreateCoinEvent object`);
      }

      const gotTypeArgs = parseTypeName(data.bcs.type).typeArgs;
      if (gotTypeArgs.length !== 1) {
        throw new Error(`type argument mismatch: expected 1 type argument but got '${gotTypeArgs.length}'`);
      }
      const gotTypeArg = compressSuiType(gotTypeArgs[0]);
      const expectedTypeArg = compressSuiType(extractType(typeArg));
      if (gotTypeArg !== compressSuiType(extractType(typeArg))) {
        throw new Error(`type argument mismatch: expected '${expectedTypeArg}' but got '${gotTypeArg}'`);
      }

      return CreateCoinEvent.fromBcs(typeArg, fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return CreateCoinEvent.fromSuiParsedData(typeArg, data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.',
    );
  }

  static async fetch<T0 extends PhantomReified<PhantomTypeArgument>>(
    client: SuiClient,
    typeArg: T0,
    id: string,
  ): Promise<CreateCoinEvent<ToPhantomTypeArgument<T0>>> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching CreateCoinEvent object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isCreateCoinEvent(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a CreateCoinEvent object`);
    }

    return CreateCoinEvent.fromSuiObjectData(typeArg, res.data);
  }
}
