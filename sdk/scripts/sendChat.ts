import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { Transaction } from '@mysten/sui/transactions';
import { Justchat } from '../src/moveCall/justchat';
import { faucetDevnet } from '../src/suiClientUtils';

// Use a default message
const message = 'Hello, World from Bumpwin!';

// Initialize client with devnet
const client = new SuiClient({ url: getFullnodeUrl('devnet') });

// Setup keypair
const keypair = Ed25519Keypair.generate();
const address = keypair.toSuiAddress();
console.log('🔑 Address:', address);
console.log('💬 Message:', message);
console.log('🌐 Network: devnet');

// Main function to execute
async function main() {
  try {
    // Request gas from faucet
    console.log('💧 Requesting SUI from faucet...');
    await faucetDevnet(client, address);
    console.log('💰 SUI requested, waiting 5 seconds for confirmation...');
    await new Promise((resolve) => setTimeout(resolve, 5000));

    // Create and send message
    await sendChatMessage(message, address);
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

// Send chat message function
async function sendChatMessage(text: string, sender: string) {
  try {
    // Create transaction
    const tx = new Transaction();
    tx.setSender(sender);
    tx.setGasBudget(100_000_000); // Set appropriate gas budget

    // Initialize Justchat and add message operation
    console.log('🤖 Initializing Justchat with devnet');
    const justchat = new Justchat('devnet');

    console.log('✏️ Adding message to transaction');
    justchat.sendMessage(tx, {
      message: text,
      sender,
    });

    console.log('📝 Signing transaction...');
    const builtTx = await tx.build({ client });
    console.log('🔍 Transaction built successfully');

    const signature = await keypair.signTransaction(builtTx);
    console.log('✅ Transaction signed successfully');

    console.log('🚀 Executing transaction...');
    const result = await client.executeTransactionBlock({
      transactionBlock: builtTx,
      signature: signature.signature,
      options: {
        showEffects: true,
        showEvents: true,
        showObjectChanges: true,
      },
    });

    // Log results
    const digest = result.digest;
    console.log('✅ Transaction executed successfully!');
    console.log('📋 Transaction digest:', digest);
    console.log(`🔗 View on explorer: https://suiscan.xyz/devnet/tx/${digest}`);

    if (result.effects?.status.status === 'success') {
      console.log('✅ Message sent successfully!');
    } else {
      console.error('❌ Transaction failed:', result.effects?.status);
    }

    // Print events if available
    if (result.events && result.events.length > 0) {
      console.log('\n📊 Events:');
      result.events.forEach((event, i) => {
        console.log(`Event ${i + 1}:`, JSON.stringify(event, null, 2));
      });
    }

    return result;
  } catch (error) {
    console.error('❌ Transaction error:', error);
    throw error;
  }
}

// Run the main function
main();
