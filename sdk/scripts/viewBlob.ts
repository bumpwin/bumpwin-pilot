import { editableCoinMetadata } from "../src/mockdata/mockdata";

async function downloadImageAsBlob(url: string): Promise<Blob> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download image: ${response.statusText}`);
  }
  return await response.blob();
}

async function main() {
  for (const coin of editableCoinMetadata) {
    try {
      const blob = await downloadImageAsBlob(coin.iconUrl);
      console.log(`\nCoin: ${coin.name} (${coin.symbol})`);
      console.log(`Blob size: ${blob.size} bytes`);
      console.log(`Blob type: ${blob.type}`);
    } catch (error) {
      console.error(`Error downloading ${coin.name}:`, error);
    }
  }
}

main().catch(console.error);


