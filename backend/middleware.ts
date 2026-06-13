import { type NextRequest, NextResponse } from "next/server";

const frontendOrigin =
  process.env.FRONTEND_ORIGIN?.replace(/\/$/, "") ??
  (process.env.VERCEL === "1" ? "https://pettrack-frontend.vercel.app" : "http://localhost:1575");

function corsHeaders(): HeadersInit {
  return {
    "Access-Control-Allow-Origin": frontendOrigin,
    "Access-Control-Allow-Credentials": "true",
    "Access-Control-Allow-Methods": "GET, DELETE, PATCH, POST, PUT, OPTIONS",
    "Access-Control-Allow-Headers":
      "X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization",
    "Access-Control-Max-Age": "86400",
  };
}

export function middleware(request: NextRequest) {
  if (request.method === "OPTIONS") {
    return new NextResponse(null, {
      status: 204,
      headers: corsHeaders(),
    });
  }

  const response = NextResponse.next();
  for (const [key, value] of Object.entries(corsHeaders())) {
    response.headers.set(key, value);
  }
  return response;
}

export const config = {
  matcher: "/api/:path*",
};
