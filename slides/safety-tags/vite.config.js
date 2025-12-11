import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    rollupOptions: {
      external: ['@slidev/types'], // 将 @slidev/types 标记为外部模块
    },
  },
});
