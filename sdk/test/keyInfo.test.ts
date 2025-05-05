import { getKeyInfoFromAlias } from './keyInfo';

describe('getKeyInfoFromAlias', () => {
  it('should correctly restore Alice\'s address', () => {
    const aliceKeyInfo = getKeyInfoFromAlias('alice');
    expect(aliceKeyInfo).not.toBeNull();
    expect(aliceKeyInfo?.address).toBe('0x2171fd4369dd716443684d5de72f7dfb7605fc4a763a5a8bdbb5efa749555c00');
  });
}); 