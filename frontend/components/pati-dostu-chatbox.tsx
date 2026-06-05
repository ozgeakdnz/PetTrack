"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { PawPrint } from "lucide-react";

export function PatiDostuChatbox() {
  const pathname = usePathname();

  if (pathname === "/assistant") {
    return null;
  }

  return (
    <Link
      href="/assistant"
      className="fixed right-4 bottom-4 z-50 inline-flex items-center gap-3 rounded-full bg-teal-600 px-5 py-3 text-white shadow-lg shadow-teal-700/25 transition hover:bg-teal-700"
      aria-label="Pati Dostu AI sayfasına git"
    >
      <PawPrint size={18} />
      <span className="leading-tight text-left">
        <span className="block text-base font-bold">Pati Dostu</span>
        <span className="block text-sm font-semibold">AI Botu</span>
      </span>
    </Link>
  );
}
