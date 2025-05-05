interface EditableCoinMetadataFields {
  name: string;
  symbol: string;
  description: string;
  iconUrl: string;
}

export const editableCoinMetadata: EditableCoinMetadataFields[] = [
  {
    name: 'Aqualien',
    symbol: 'AQLN',
    description:
      'An interdimensional aquatic lifeform believed to cause flash rugpulls whenever observed. Possibly sentient liquidity.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900000/sample.jpg',
  },
  {
    name: 'BlowFi',
    symbol: 'BLWF',
    description:
      'A pufferfish-shaped DeFi protocol that inflates yield—and risk. Handle with care. May explode on-chain.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900001/sample.jpg',
  },
  {
    name: 'ClutchSquid',
    symbol: 'CLSQ',
    description:
      "An angry purple squid that believes it's the MVP of every memecoin showdown. Always misses the entry.",
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900002/sample.jpg',
  },
  {
    name: 'Dripfin',
    symbol: 'DRIP',
    description:
      'A tropical fish token that promises dripping rewards and evaporating APRs. Beautiful and brief.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900003/sample.jpg',
  },
  {
    name: 'Frogmentum',
    symbol: 'FGM',
    description:
      "Jumping 500% per hop, this frog lives on hope and hopium. The pump is real—until it's not.",
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900004/sample.jpg',
  },
  {
    name: 'Jelloo',
    symbol: 'JLOO',
    description:
      'A jellyfish coin for holders who stopped thinking. Soft, squishy, and drifts into top 100 overnight.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900005/sample.jpg',
  },
  {
    name: 'Memephibian',
    symbol: 'MEMB',
    description:
      'Neither frog nor fish. A hybrid meme creature that thrives in volatility and shitcoin soup.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900006/sample.jpg',
  },
  {
    name: 'Moistie',
    symbol: 'MST',
    description:
      'A coelacanth-style relic for ancient holders. Still alive. Still underwater. Still waiting to break even.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900007/sample.jpg',
  },
  {
    name: 'Nyanomaly',
    symbol: 'NYAN',
    description:
      'Pixel cat anomaly from a forgotten blockchain. Pumps when the chart forms a rainbow.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900008/sample.jpg',
  },
  {
    name: 'Purrdex',
    symbol: 'PURR',
    description:
      'A feline-powered decentralized exchange where trades are silent and exits are suspiciously elegant.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900009/sample.jpg',
  },
  {
    name: 'Rugtopus',
    symbol: 'RUGT',
    description:
      'Eight tentacles, eight tokens rugged. Master of multi-wallet rugpulling. Hugs your funds goodbye.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900010/sample.jpg',
  },
  {
    name: 'SniffDAO',
    symbol: 'SNIF',
    description:
      'A DAO powered by Beagle-grade alpha detection. Sniffs out trends before they trend—or before they die.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900011/sample.jpg',
  },
  {
    name: 'WagmiWhale',
    symbol: 'WGMW',
    description:
      'A baby whale who believes in you. And in the bag. The purest WAGMI energy in the memeverse.',
    iconUrl: 'https://res.cloudinary.com/demo/image/upload/v1714900012/sample.jpg',
  },
] as const;
