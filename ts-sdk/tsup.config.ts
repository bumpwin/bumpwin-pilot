import { defineConfig } from 'tsup';

export default defineConfig([
  {
    entry: {
      index: 'src/index.ts',
      'suigen/index': 'src/suigen/index.ts',
    },
    format: ['esm'],
    dts: true,
    clean: true,
    outDir: 'dist/esm',
    splitting: false,
    treeshake: true,
    sourcemap: true,
    minify: false,
    shims: true,
    platform: 'node',
    target: 'node18',
  },
  {
    entry: {
      index: 'src/index.ts',
      'suigen/index': 'src/suigen/index.ts',
    },
    format: ['cjs'],
    dts: false,
    outDir: 'dist/cjs',
    splitting: false,
    treeshake: true,
    sourcemap: true,
    minify: false,
    shims: true,
    platform: 'node',
    target: 'node18',
  },
]);
