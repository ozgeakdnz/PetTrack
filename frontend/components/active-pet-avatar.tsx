"use client";

import { useActivePet } from "@/lib/active-pet-context";
import { formatPetAge, formatPetWeight } from "@/lib/pet-display";
import { resolvePetImageSrc } from "@/lib/pet-avatar";

type ActivePetAvatarProps = {
  className?: string;
};

const badgeShell =
  "inline-flex shrink-0 items-center gap-3 rounded-full border border-slate-200 bg-slate-100 py-1 pl-1 pr-5 shadow-sm";

export function ActivePetAvatar({ className = "" }: ActivePetAvatarProps) {
  const { activePet, loading } = useActivePet();

  if (loading) {
    return (
      <div className={`${badgeShell} h-[52px] min-w-[160px] animate-pulse ${className}`} aria-hidden>
        <div className="h-11 w-11 rounded-full bg-slate-200" />
        <div className="space-y-1.5">
          <div className="h-3 w-16 rounded bg-slate-200" />
          <div className="h-2.5 w-24 rounded bg-slate-200" />
        </div>
      </div>
    );
  }

  if (!activePet) {
    return null;
  }

  const src = resolvePetImageSrc(activePet, activePet.species, null);
  const meta = `${formatPetWeight(activePet.weight)} • ${formatPetAge(activePet.birthDate)}`;

  return (
    <div title={activePet.name} className={`${badgeShell} ${className}`}>
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src={src}
        alt={`${activePet.name} profil fotoğrafı`}
        className="h-11 w-11 rounded-full object-cover ring-1 ring-white"
      />
      <div className="min-w-0 pr-0.5 text-left leading-tight">
        <p className="truncate text-sm font-bold text-slate-900">{activePet.name}</p>
        <p className="truncate text-xs text-slate-500">{meta}</p>
      </div>
    </div>
  );
}
