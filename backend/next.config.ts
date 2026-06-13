import type { NextConfig } from "next";
import path from "path";
import { fileURLToPath } from "url";

const rootDir = path.dirname(fileURLToPath(import.meta.url));

const frontendOrigin =
  process.env.FRONTEND_ORIGIN?.replace(/\/$/, "") ?? "https://pettrack-frontend.vercel.app";

const nextConfig: NextConfig = {
  turbopack: {
    root: path.join(rootDir, ".."),
  },
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
    ],
  },
  async headers() {
    return [
      {
        source: "/api/:path*",
        headers: [
          { key: "Access-Control-Allow-Credentials", value: "true" },
          { key: "Access-Control-Allow-Origin", value: frontendOrigin },
          {
            key: "Access-Control-Allow-Methods",
            value: "GET, DELETE, PATCH, POST, PUT, OPTIONS",
          },
          {
            key: "Access-Control-Allow-Headers",
            value:
              "X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
