/** Runtime configuration. EXPO_PUBLIC_* variables are inlined at build time. */
export function resolveApiUrl(value: string | undefined): string {
  const url = (value ?? '').trim().replace(/\/+$/, '');
  if (!url) return 'http://localhost:8080';
  if (!/^https?:\/\//.test(url)) {
    throw new Error(`EXPO_PUBLIC_API_URL must start with http:// or https:// (got "${url}")`);
  }
  return url;
}

export const config = {
  apiUrl: resolveApiUrl(process.env.EXPO_PUBLIC_API_URL),
} as const;
