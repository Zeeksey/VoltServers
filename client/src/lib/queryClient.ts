import { QueryClient, QueryFunction } from "@tanstack/react-query";

async function throwIfResNotOk(res: Response) {
  if (!res.ok) {
    const text = (await res.text()) || res.statusText;
    throw new Error(`${res.status}: ${text}`);
  }
}

export async function apiRequest(
  method: string,
  url: string,
  data?: unknown | undefined,
): Promise<Response> {
  const res = await fetch(url, {
    method,
    headers: data ? { "Content-Type": "application/json" } : {},
    body: data ? JSON.stringify(data) : undefined,
    credentials: "include",
  });

  await throwIfResNotOk(res);
  return res;
}

type UnauthorizedBehavior = "returnNull" | "throw";
export const getQueryFn: <T>(options: {
  on401: UnauthorizedBehavior;
}) => QueryFunction<T> =
  ({ on401: unauthorizedBehavior }) =>
  async ({ queryKey }) => {
    const res = await fetch(queryKey.join("/") as string, {
      credentials: "include",
    });

    if (unauthorizedBehavior === "returnNull" && res.status === 401) {
      return null;
    }

    await throwIfResNotOk(res);
    return await res.json();
  };

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: getQueryFn({ on401: "throw" }),
      refetchInterval: false,
      refetchOnWindowFocus: false,
      staleTime: 60 * 60 * 1000, // 1 hour - prevent frequent refetches that cause flashing
      gcTime: 2 * 60 * 60 * 1000, // 2 hours cache to keep data longer
      retry: (failureCount, error) => {
        // Don't retry on 4xx errors for faster failure
        if (error.message.includes('4')) return false;
        return failureCount < 2; // Reduce retries for speed
      },
      retryDelay: attemptIndex => Math.min(500 * 2 ** attemptIndex, 10000), // Faster retry delays
      notifyOnChangeProps: ['data', 'isLoading', 'error'], // Only notify on essential changes
    },
    mutations: {
      retry: 1,
      retryDelay: 500,
    },
  },
});
