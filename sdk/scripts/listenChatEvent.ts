import process from 'node:process';
import { EventFetcher } from '../src/events/justchat';
import type { EventId } from '@mysten/sui/client';

async function main() {
  try {
    const fetcher = new EventFetcher({
      network: 'testnet',
      eventQueryLimit: 10,
    });

    console.log('🚀 Starting to poll for chat events...');

    // Track processed event IDs
    const processedEventIds = new Set<string>();
    let cursor: EventId | null = null;

    // Polling interval in milliseconds
    const POLLING_INTERVAL_MS = 5000;

    const intervalId = setInterval(async () => {
      try {
        const result = await fetcher.fetch(cursor);

        // Filter only new events
        const newEvents = result.events.filter((event) => {
          const eventId = `${event.digest}-${event.sequence}`;
          return !processedEventIds.has(eventId);
        });

        if (newEvents.length > 0) {
          console.log(`[${new Date().toISOString()}] Found ${newEvents.length} new event(s)`);

          for (const event of newEvents) {
            console.log('----------------------------------------');
            console.log(`  Event Digest: ${event.digest}`);
            console.log(`  Event Sequence: ${event.sequence}`);
            console.log(`  Timestamp: ${event.timestamp}`);
            console.log(`  Sender: ${event.sender}`);
            console.log(`  Text: "${event.text}"`);

            // Mark event as processed
            processedEventIds.add(`${event.digest}-${event.sequence}`);
          }
        }

        // Update cursor
        cursor = result.cursor;
      } catch (error) {
        console.error('Error in polling loop:', error);
      }
    }, POLLING_INTERVAL_MS);

    console.log('Polling script is running. Press Ctrl+C to stop.');

    // Keep process running
    process.stdin.resume();
    process.on('SIGINT', () => {
      clearInterval(intervalId);
      console.log('\nShutting down polling script...');
      process.exit(0);
    });
  } catch (error) {
    console.error('Failed to start polling script:', error);
    process.exit(1);
  }
}

// Run the main function
main();
