import { resolveApiUrl } from './config';

describe('resolveApiUrl', () => {
  it('defaults to the local API', () => {
    expect(resolveApiUrl(undefined)).toBe('http://localhost:8080');
  });

  it('strips trailing slashes', () => {
    expect(resolveApiUrl('https://api.example.com//')).toBe('https://api.example.com');
  });

  it('rejects URLs without a scheme', () => {
    expect(() => resolveApiUrl('api.example.com')).toThrow(/must start with/);
  });
});
