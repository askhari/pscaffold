import createFetchClient, { type Middleware } from 'openapi-fetch';
import createReactQueryClient from 'openapi-react-query';

import type { paths } from './generated/schema';

export type { components, paths } from './generated/schema';

export interface ApiClientOptions {
  baseUrl: string;
  /** Returns the current access token, if any. Called for every request. */
  getAccessToken?: () => string | undefined | Promise<string | undefined>;
  fetch?: typeof globalThis.fetch;
}

/** Typed HTTP client generated from contract/openapi.yaml. */
export function createApiClient({ baseUrl, getAccessToken, fetch }: ApiClientOptions) {
  const client = createFetchClient<paths>({ baseUrl, fetch });
  if (getAccessToken) {
    const auth: Middleware = {
      async onRequest({ request }) {
        const token = await getAccessToken();
        if (token) request.headers.set('Authorization', `Bearer ${token}`);
        return request;
      },
    };
    client.use(auth);
  }
  return client;
}

export type ApiClient = ReturnType<typeof createApiClient>;

/** TanStack Query bindings: `$api.useQuery('get', '/healthz')`. */
export function createQueryApi(client: ApiClient) {
  return createReactQueryClient(client);
}
