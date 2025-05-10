import { bcs } from '@mysten/sui/bcs';
import type { SuiClient, SuiObjectData, SuiParsedData } from '@mysten/sui/client';
import { fromB64, fromHEX, toHEX } from '@mysten/sui/utils';
import { String } from '../../_dependencies/onchain/0x1/string/structs';
import {
  type PhantomReified,
  type Reified,
  type StructClass,
  type ToField,
  type ToTypeStr,
  decodeFromFields,
  decodeFromFieldsWithTypes,
  decodeFromJSONField,
  phantom,
} from '../../_framework/reified';
import { type FieldsWithTypes, composeSuiType, compressSuiType } from '../../_framework/util';
import { PKG_V1 } from '../index';

/* ============================== MessageReceivedEvent =============================== */

export function isMessageReceivedEvent(type: string): boolean {
  type = compressSuiType(type);
  return type === `${PKG_V1}::messaging::MessageReceivedEvent`;
}

export interface MessageReceivedEventFields {
  sender: ToField<'address'>;
  recipient: ToField<'address'>;
  text: ToField<String>;
  amount: ToField<'u64'>;
}

export type MessageReceivedEventReified = Reified<MessageReceivedEvent, MessageReceivedEventFields>;

export class MessageReceivedEvent implements StructClass {
  __StructClass = true as const;

  static readonly $typeName = `${PKG_V1}::messaging::MessageReceivedEvent`;
  static readonly $numTypeParams = 0;
  static readonly $isPhantom = [] as const;

  readonly $typeName = MessageReceivedEvent.$typeName;
  readonly $fullTypeName: `${typeof PKG_V1}::messaging::MessageReceivedEvent`;
  readonly $typeArgs: [];
  readonly $isPhantom = MessageReceivedEvent.$isPhantom;

  readonly sender: ToField<'address'>;
  readonly recipient: ToField<'address'>;
  readonly text: ToField<String>;
  readonly amount: ToField<'u64'>;

  private constructor(typeArgs: [], fields: MessageReceivedEventFields) {
    this.$fullTypeName = composeSuiType(
      MessageReceivedEvent.$typeName,
      ...typeArgs
    ) as `${typeof PKG_V1}::messaging::MessageReceivedEvent`;
    this.$typeArgs = typeArgs;

    this.sender = fields.sender;
    this.recipient = fields.recipient;
    this.text = fields.text;
    this.amount = fields.amount;
  }

  static reified(): MessageReceivedEventReified {
    return {
      typeName: MessageReceivedEvent.$typeName,
      fullTypeName: composeSuiType(
        MessageReceivedEvent.$typeName,
        ...[]
      ) as `${typeof PKG_V1}::messaging::MessageReceivedEvent`,
      typeArgs: [] as [],
      isPhantom: MessageReceivedEvent.$isPhantom,
      reifiedTypeArgs: [],
      fromFields: (fields: Record<string, any>) => MessageReceivedEvent.fromFields(fields),
      fromFieldsWithTypes: (item: FieldsWithTypes) =>
        MessageReceivedEvent.fromFieldsWithTypes(item),
      fromBcs: (data: Uint8Array) => MessageReceivedEvent.fromBcs(data),
      bcs: MessageReceivedEvent.bcs,
      fromJSONField: (field: any) => MessageReceivedEvent.fromJSONField(field),
      fromJSON: (json: Record<string, any>) => MessageReceivedEvent.fromJSON(json),
      fromSuiParsedData: (content: SuiParsedData) =>
        MessageReceivedEvent.fromSuiParsedData(content),
      fromSuiObjectData: (content: SuiObjectData) =>
        MessageReceivedEvent.fromSuiObjectData(content),
      fetch: async (client: SuiClient, id: string) => MessageReceivedEvent.fetch(client, id),
      new: (fields: MessageReceivedEventFields) => {
        return new MessageReceivedEvent([], fields);
      },
      kind: 'StructClassReified',
    };
  }

  static get r() {
    return MessageReceivedEvent.reified();
  }

  static phantom(): PhantomReified<ToTypeStr<MessageReceivedEvent>> {
    return phantom(MessageReceivedEvent.reified());
  }
  static get p() {
    return MessageReceivedEvent.phantom();
  }

  static get bcs() {
    return bcs.struct('MessageReceivedEvent', {
      sender: bcs.bytes(32).transform({
        input: (val: string) => fromHEX(val),
        output: (val: Uint8Array) => toHEX(val),
      }),
      recipient: bcs.bytes(32).transform({
        input: (val: string) => fromHEX(val),
        output: (val: Uint8Array) => toHEX(val),
      }),
      text: String.bcs,
      amount: bcs.u64(),
    });
  }

  static fromFields(fields: Record<string, any>): MessageReceivedEvent {
    return MessageReceivedEvent.reified().new({
      sender: decodeFromFields('address', fields.sender),
      recipient: decodeFromFields('address', fields.recipient),
      text: decodeFromFields(String.reified(), fields.text),
      amount: decodeFromFields('u64', fields.amount),
    });
  }

  static fromFieldsWithTypes(item: FieldsWithTypes): MessageReceivedEvent {
    if (!isMessageReceivedEvent(item.type)) {
      throw new Error('not a MessageReceivedEvent type');
    }

    return MessageReceivedEvent.reified().new({
      sender: decodeFromFieldsWithTypes('address', item.fields.sender),
      recipient: decodeFromFieldsWithTypes('address', item.fields.recipient),
      text: decodeFromFieldsWithTypes(String.reified(), item.fields.text),
      amount: decodeFromFieldsWithTypes('u64', item.fields.amount),
    });
  }

  static fromBcs(data: Uint8Array): MessageReceivedEvent {
    return MessageReceivedEvent.fromFields(MessageReceivedEvent.bcs.parse(data));
  }

  toJSONField() {
    return {
      sender: this.sender,
      recipient: this.recipient,
      text: this.text,
      amount: this.amount.toString(),
    };
  }

  toJSON() {
    return { $typeName: this.$typeName, $typeArgs: this.$typeArgs, ...this.toJSONField() };
  }

  static fromJSONField(field: any): MessageReceivedEvent {
    return MessageReceivedEvent.reified().new({
      sender: decodeFromJSONField('address', field.sender),
      recipient: decodeFromJSONField('address', field.recipient),
      text: decodeFromJSONField(String.reified(), field.text),
      amount: decodeFromJSONField('u64', field.amount),
    });
  }

  static fromJSON(json: Record<string, any>): MessageReceivedEvent {
    if (json.$typeName !== MessageReceivedEvent.$typeName) {
      throw new Error('not a WithTwoGenerics json object');
    }

    return MessageReceivedEvent.fromJSONField(json);
  }

  static fromSuiParsedData(content: SuiParsedData): MessageReceivedEvent {
    if (content.dataType !== 'moveObject') {
      throw new Error('not an object');
    }
    if (!isMessageReceivedEvent(content.type)) {
      throw new Error(
        `object at ${(content.fields as any).id} is not a MessageReceivedEvent object`
      );
    }
    return MessageReceivedEvent.fromFieldsWithTypes(content);
  }

  static fromSuiObjectData(data: SuiObjectData): MessageReceivedEvent {
    if (data.bcs) {
      if (data.bcs.dataType !== 'moveObject' || !isMessageReceivedEvent(data.bcs.type)) {
        throw new Error(`object at is not a MessageReceivedEvent object`);
      }

      return MessageReceivedEvent.fromBcs(fromB64(data.bcs.bcsBytes));
    }
    if (data.content) {
      return MessageReceivedEvent.fromSuiParsedData(data.content);
    }
    throw new Error(
      'Both `bcs` and `content` fields are missing from the data. Include `showBcs` or `showContent` in the request.'
    );
  }

  static async fetch(client: SuiClient, id: string): Promise<MessageReceivedEvent> {
    const res = await client.getObject({ id, options: { showBcs: true } });
    if (res.error) {
      throw new Error(`error fetching MessageReceivedEvent object at id ${id}: ${res.error.code}`);
    }
    if (res.data?.bcs?.dataType !== 'moveObject' || !isMessageReceivedEvent(res.data.bcs.type)) {
      throw new Error(`object at id ${id} is not a MessageReceivedEvent object`);
    }

    return MessageReceivedEvent.fromSuiObjectData(res.data);
  }
}
