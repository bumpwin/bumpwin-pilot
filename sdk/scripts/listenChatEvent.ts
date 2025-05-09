// Sui Client and utilities for interacting with the Sui network
import { SuiClient, getFullnodeUrl, type EventId } from '@mysten/sui/client';

// Import the PACKAGE_ID from suigen generated index file
import { PACKAGE_ID } from '../src/suigen/justchat/index'; // Corrected import for PACKAGE_ID

// Suigen generated types and constants for the 'justchat' package
// PKG_V1 should be the deployed package ID of your 'justchat' module.
// This is usually configured in your suigen .toml file and reflected in init.ts.
// import { PKG_V1 } from '../src/suigen/justchat/init'; // Removed PKG_V1 import
import {
  MessageReceivedEvent,
  isMessageReceivedEvent,
  type MessageReceivedEventFields, // Import the type for parsedJson
} from '../src/suigen/justchat/messaging/structs';

// --- Configuration ---
const SUI_NETWORK: 'testnet' | 'devnet' | 'mainnet' = 'testnet'; // Set your target network
const POLLING_INTERVAL_MS = 5000; // How often to check for new events (in milliseconds)
const EVENT_QUERY_LIMIT = 10; // Max events to fetch per poll
// const HARDCODED_PACKAGE_ID = "0x366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3"; // Removed hardcoded ID

// Construct the Sui Client
const fullnodeUrl = getFullnodeUrl(SUI_NETWORK);
const suiClient = new SuiClient({ url: fullnodeUrl });

// Derive the full event type string using the imported PACKAGE_ID.
const TARGET_EVENT_TYPE = `${PACKAGE_ID}::messaging::MessageReceivedEvent`;

/**
 * Polls the Sui network for MessageReceivedEvent events from the justchat package.
 */
async function pollJustChatEvents() {
  console.log(`🚀 Starting to poll for ${TARGET_EVENT_TYPE} events on ${SUI_NETWORK}...`);
  console.log(`Network RPC: ${fullnodeUrl}`);
  console.log(`Package ID (from suigen): ${PACKAGE_ID}`); // Updated log to use imported PACKAGE_ID

  // Warning if the package ID looks like a placeholder - This check might need adjustment
  // based on how suigen actually populates PACKAGE_ID if it's missing/default.
  if (PACKAGE_ID.startsWith('0x00000000') || PACKAGE_ID.length < 60) {
    console.warn(`🚨 WARNING: The Package ID ("${PACKAGE_ID}") from suigen output looks like a placeholder or might be incorrect.`);
    console.warn(`👉 Please ensure your suigen configuration (e.g., ../suigen-configs/testnet.toml for 'justchat') contains the correct deployed package ID.`);
    // const justfilePackageId = "0x366ffbcaf9c51db02857ff81141702f114f3b5675dd960be74f3c5f34e2ba3c3"; // This reference can be removed or kept for info
    // console.warn(`ℹ️ Your justfile lists this package ID for messaging: ${justfilePackageId}. If PACKAGE_ID is wrong, suigen needs to be run with the correct ID.`);
    console.warn(`The script will try to use "${TARGET_EVENT_TYPE}", but may not find events if the ID is wrong.`);
  }

  let cursor: EventId | null = null; // Stores the cursor for paginating through events - Corrected type

  // Indefinitely poll for events at the specified interval
  setInterval(async () => {
    try {
      const eventPage = await suiClient.queryEvents({
        query: {
          MoveEventType: TARGET_EVENT_TYPE,
        },
        cursor: cursor,
        limit: EVENT_QUERY_LIMIT,
        order: 'ascending', // Process events in the order they occurred
      });

      if (eventPage.data && eventPage.data.length > 0) {
        console.log(
          `[${new Date().toISOString()}] Found ${eventPage.data.length} event(s) matching ${TARGET_EVENT_TYPE}:`
        );

        for (const event of eventPage.data) {
          // Double-check the event type using the suigen helper, though the query filter should handle this.
          if (isMessageReceivedEvent(event.type)) {
            console.log('----------------------------------------');
            console.log(`  Event Digest: ${event.id.txDigest}`);
            console.log(`  Event Sequence: ${event.id.eventSeq}`);
            const timestamp = event.timestampMs
              ? new Date(parseInt(event.timestampMs)).toISOString()
              : 'N/A';
            console.log(`  Timestamp: ${timestamp}`);

            // event.parsedJson contains the structured event data.
            // We use MessageReceivedEvent.fromFields to get a typed object.
            try {
              // Cast parsedJson to the Fields type for the fromFields method.
              // const parsedEventData = event.parsedJson as MessageReceivedEventFields;
              // const chatEvent = MessageReceivedEvent.fromFields(parsedEventData);

              // console.log(`  Sender: ${chatEvent.sender}`);
              // // console.log(`  Content: "${chatEvent.content}"`); // Commented out, field might not exist
              // // console.log(`  Fee Address: ${chatEvent.fee_address}`); // Commented out, field might not exist
              // // TODO: Verify the actual field names in MessageReceivedEventFields from sdk/src/suigen/justchat/messaging/structs.ts
              // // Example: if the field is 'message_content', use chatEvent.message_content
              // // Example: if the field is 'payer_address', use chatEvent.payer_address
              // // For now, logging all fields found in parsedEventData for inspection:
              // console.log('  Event Fields (parsedJson):', parsedEventData);

              // New approach: Directly use event.parsedJson cast to MessageReceivedEventFields
              const chatEventData = event.parsedJson as MessageReceivedEventFields;

              console.log(`  Sender: ${chatEventData.sender}`);
              console.log(`  Text: "${chatEventData.text}"`); // Assuming 'text' holds the message content

              // Optionally log other fields if they are present and defined in MessageReceivedEventFields
              // For example, based on the previous raw log:
              // if (typeof chatEventData.recipient === 'string') {
              //   console.log(`  Recipient: ${chatEventData.recipient}`);
              // }
              // if (typeof chatEventData.amount === 'string') { // Or number, depending on the type
              //   console.log(`  Amount: ${chatEventData.amount}`);
              // }

            } catch (e) {
              console.error('  Error interpreting event fields from parsedJson:', e);
              console.error('  Raw parsedJson (for reference):', event.parsedJson);
            }
          } else {
            // This should ideally not be reached if the MoveEventType filter is correct.
            console.warn(`  Skipping event with unexpected type: ${event.type}`);
          }
        }

        // Update the cursor to the `nextCursor` from the response.
        // This allows the next poll to fetch subsequent events.
        if (eventPage.hasNextPage && eventPage.nextCursor) {
          cursor = eventPage.nextCursor;
        }
        // If !hasNextPage, the current cursor is the most recent one,
        // and the next poll with this cursor will get any newer events.
      } else {
        // console.log(`[${new Date().toISOString()}] No new ${TARGET_EVENT_TYPE} events found in this interval.`);
      }
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Error polling for events:`, error);
      // Consider more sophisticated error handling, like resetting the client or cursor on certain errors.
    }
  }, POLLING_INTERVAL_MS);
}

/**
 * Main function to start the event polling script.
 */
async function main() {
  try {
    await pollJustChatEvents();
    console.log('Polling script is now running. Press Ctrl+C to stop.');

    // Keep the script alive until manually stopped
    process.stdin.resume(); // Allows the process to stay alive
    process.on('SIGINT', () => {
      console.log('\nGracefully shutting down polling script...');
      process.exit(0);
    });
  } catch (error) {
    console.error('Failed to initialize or start the polling script:', error);
    process.exit(1);
  }
}

// Run the main function
main();
