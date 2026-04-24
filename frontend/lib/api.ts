/**
 * Backend taban URL'i. Yerel geliştirmede backend varsayılan portu 1571.
 * Üretimde `.env.local` içinde `NEXT_PUBLIC_API_URL` tanımlayın.
 */
export function apiUrl(path: string): string {
  const base = (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:1571").replace(/\/$/, "");
  const normalized = path.startsWith("/") ? path : `/${path}`;
  return `${base}${normalized}`;
}
