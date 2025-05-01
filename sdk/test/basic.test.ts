// test/basic.test.ts
import { describe, expect, it } from 'vitest';
import { hello } from '../src';

describe('hello()', () => {
  it('returns greeting', () => {
    expect(hello()).toBe('Hello SDK world');
  });
});
