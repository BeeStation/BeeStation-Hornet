module.exports = {
  roots: ['<rootDir>/packages'],
  testMatch: ['<rootDir>/packages/**/__tests__/*.{js,jsx,ts,tsx}', '<rootDir>/packages/**/*.{spec,test}.{js,jsx,ts,tsx}'],
  testPathIgnorePatterns: ['<rootDir>/packages/tgui-bench'],
  testEnvironment: 'jsdom',
  testRunner: require.resolve('jest-circus/runner'),
  transform: {
    '^.+\\.(js|jsx|cjs|ts|tsx)$': require.resolve('@swc/jest'),
  },
  moduleFileExtensions: ['js', 'jsx', 'cjs', 'ts', 'tsx', 'json'],
  resetMocks: true,
};
