/**
 * Python FastAPI backend (backend-py). Varsayılan port 1572.
 * Üretimde `NEXT_PUBLIC_PY_API_URL` tanımlayın.
 */
export function pyApiUrl(path: string): string {
  const base = (process.env.NEXT_PUBLIC_PY_API_URL ?? "http://localhost:1572").replace(/\/$/, "");
  const normalized = path.startsWith("/") ? path : `/${path}`;
  return `${base}${normalized}`;
}
