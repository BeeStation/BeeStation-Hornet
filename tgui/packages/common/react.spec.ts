import { describe, expect, it } from 'bun:test';

/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */
import { classes } from './react';

describe('classes', () => {
  it('empty', () => {
    expect(classes([])).toBe('');
  });

  it('result contains inputs', () => {
    const output = classes(['foo', 'bar', false, true, 0, 1, 'baz']);
    expect(output).toContain('foo');
    expect(output).toContain('bar');
    expect(output).toContain('baz');
  });
});
