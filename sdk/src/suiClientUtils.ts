import { Transaction } from '@mysten/sui/transactions';
import { SuiClient } from '@mysten/sui/client';
import { getFaucetHost } from '@mysten/sui/faucet';
import type { MoveBytecode } from './types';

const toBytes = (b64: string) => {
  const binary = atob(b64);
  return Array.from(binary).map((c) => c.charCodeAt(0));
};

export const publish = (
  tx: Transaction,
  args: {
    moveBytecode: MoveBytecode;
    sender: string;
  }
): void => {
  const modules = args.moveBytecode.modules.map(toBytes);
  const dependencies = [...args.moveBytecode.dependencies];

  const [upgradeCap] = tx.publish({ modules, dependencies });
  tx.transferObjects([upgradeCap], args.sender);
};

export const faucetDevnet = async (client: SuiClient, address: string): Promise<void> => {
  console.log('⛲ Requesting SUI from faucet...');
  const faucetUrl = `${getFaucetHost('devnet')}/v2/gas`;
  const faucetResponse = await fetch(faucetUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      FixedAmountRequest: {
        recipient: address,
      },
    }),
  });

  if (!faucetResponse.ok) {
    throw new Error(`Faucet request failed with status ${faucetResponse.status}`);
  }

  const faucetData = await faucetResponse.json();
  console.log('Faucet response:', JSON.stringify(faucetData, null, 2));

  if (!faucetData.coins_sent || faucetData.coins_sent.length === 0) {
    throw new Error('Failed to get gas objects from faucet response');
  }

  await client.waitForTransaction({ digest: faucetData.coins_sent[0].transferTxDigest });
  console.log('✅ Faucet funded');
};
