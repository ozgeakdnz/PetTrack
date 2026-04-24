# Geliştirme (frontend + backend)

Kök dizinde `npm install` tamamsa:

1. `backend/.env` içinde `DATABASE_URL` tanımla (ve isteğe bağlı `FRONTEND_ORIGIN=http://localhost:1570`).
2. `npm run dev` — backend **1571**, frontend **1570**.
3. İsteğe bağlı: `frontend/.env.local` içinde `NEXT_PUBLIC_API_URL=http://localhost:1571` (varsayılan zaten bu).

Tarayıcı: http://localhost:1570
