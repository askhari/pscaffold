// Contract tests: run against any running implementation of the API (Go or Rust).
// `just test-contract` starts the API and sets API_BASE_URL.
import { describe, expect, it } from 'vitest';
import { createApiClient } from '../src/index';

const baseUrl = process.env.API_BASE_URL ?? 'http://localhost:8080';
const api = createApiClient({ baseUrl });

describe('GET /healthz', () => {
  it('reports the API and database as ok', async () => {
    const { data, error, response } = await api.GET('/healthz');
    expect(error).toBeUndefined();
    expect(response.status).toBe(200);
    expect(data).toMatchObject({ status: 'ok', database: 'ok' });
    expect(typeof data?.version).toBe('string');
  });
});
