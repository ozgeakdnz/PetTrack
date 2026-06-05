import type { NextConfig } from "next";
import path from "path";
import { fileURLToPath } from "url";

const rootDir = path.dirname(fileURLToPath(import.meta.url));
const apiBase = (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:1571").replace(/\/$/, "");

const nextConfig: NextConfig = {
  turbopack: {
    root: path.join(rootDir, ".."),
  },
  async rewrites() {
    return [
      {
        source: "/uploads/:path*",
        destination: `${apiBase}/uploads/:path*`,
      },
    ];
  },
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
      {
        protocol: "http",
        hostname: "localhost",
        port: "1571",
        pathname: "/uploads/**",
      },
    ],
  },
};

export default nextConfig;
