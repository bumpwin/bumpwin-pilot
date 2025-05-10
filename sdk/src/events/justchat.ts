import {
  type EventId,
  SuiClient,
  type SuiEvent as SuiClientEvent,
  getFullnodeUrl,
} from '@mysten/sui/client';
import { PACKAGE_ID } from '../suigen/justchat/index';
import {
  type MessageReceivedEventFields,
  isMessageReceivedEvent,
} from '../suigen/justchat/messaging/structs';

export type Network = 'testnet' | 'devnet' | 'mainnet';

export interface EventFetchConfig {
  network: Network;
  eventQueryLimit?: number;
}

export interface MessageEvent {
  digest: string;
  sequence: number;
  timestamp: string;
  sender: string;
  text: string;
}

export interface EventFetchResult {
  events: MessageEvent[];
  cursor: EventId | null;
  hasNextPage: boolean;
}

/**
 * Convert event data to MessageEvent format
 */
function convertToMessageEvent(event: SuiClientEvent): MessageEvent {
  const chatEventData = event.parsedJson as MessageReceivedEventFields;
  return {
    digest: event.id.txDigest,
    sequence: Number.parseInt(event.id.eventSeq),
    timestamp: event.timestampMs
      ? new Date(Number.parseInt(event.timestampMs)).toISOString()
      : 'N/A',
    sender: chatEventData.sender,
    text: chatEventData.text,
  };
}

/**
 * Class for fetching events
 */
export class EventFetcher {
  private suiClient: SuiClient;
  private targetEventType: string;
  private eventQueryLimit: number;

  constructor(config: EventFetchConfig) {
    this.suiClient = new SuiClient({ url: getFullnodeUrl(config.network) });
    this.targetEventType = `${PACKAGE_ID}::messaging::MessageReceivedEvent`;
    this.eventQueryLimit = config.eventQueryLimit || 10;
  }

  /**
   * Fetch events
   * @param cursor Position from last fetch (null for first fetch)
   * @returns Fetched events and next cursor
   */
  async fetch(cursor: EventId | null = null): Promise<EventFetchResult> {
    try {
      const eventPage = await this.suiClient.queryEvents({
        query: { MoveEventType: this.targetEventType },
        cursor,
        limit: this.eventQueryLimit,
        order: 'ascending',
      });

      const events: MessageEvent[] = [];

      if (eventPage.data && eventPage.data.length > 0) {
        for (const event of eventPage.data) {
          if (isMessageReceivedEvent(event.type)) {
            events.push(convertToMessageEvent(event));
          }
        }
      }

      return {
        events,
        cursor: eventPage.nextCursor || null,
        hasNextPage: eventPage.hasNextPage,
      };
    } catch (error) {
      console.error('Error fetching events:', error);
      return {
        events: [],
        cursor: null,
        hasNextPage: false,
      };
    }
  }
}
