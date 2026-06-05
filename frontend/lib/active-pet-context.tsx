"use client";

import { apiUrl } from "@/lib/api";
import type { PetSpecies } from "@/lib/pet-avatar";
import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";

export type ActivePetProfile = {
  id: string;
  name: string;
  species: PetSpecies;
  imageUrl: string | null;
  weight: number | null;
  birthDate: string | null;
};

const STORAGE_KEY = "pettrack-active-pet-id";

type ActivePetContextValue = {
  pets: ActivePetProfile[];
  activePetId: string | null;
  activePet: ActivePetProfile | null;
  loading: boolean;
  setActivePetId: (id: string | null) => void;
  refreshPets: () => Promise<void>;
};

const ActivePetContext = createContext<ActivePetContextValue | null>(null);

export function useActivePet() {
  const ctx = useContext(ActivePetContext);
  if (!ctx) {
    throw new Error("useActivePet yalnızca ActivePetProvider içinde kullanılabilir.");
  }
  return ctx;
}

export function ActivePetProvider({ children }: { children: React.ReactNode }) {
  const [pets, setPets] = useState<ActivePetProfile[]>([]);
  const [activePetId, setActivePetIdState] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const setActivePetId = useCallback((id: string | null) => {
    setActivePetIdState(id);
    if (typeof window !== "undefined") {
      if (id) localStorage.setItem(STORAGE_KEY, id);
      else localStorage.removeItem(STORAGE_KEY);
    }
  }, []);

  const refreshPets = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch(apiUrl("/api/pets"), { cache: "no-store" });
      const data = (await res.json()) as { pets?: ActivePetProfile[]; error?: string };
      if (!res.ok) throw new Error(data.error ?? "Profiller alınamadı.");

      const loaded = data.pets ?? [];
      setPets(loaded);

      const stored =
        typeof window !== "undefined" ? localStorage.getItem(STORAGE_KEY) : null;
      const validStored = stored && loaded.some((pet) => pet.id === stored) ? stored : null;
      const nextId = validStored ?? loaded[0]?.id ?? null;
      setActivePetIdState(nextId);
      if (nextId && typeof window !== "undefined") {
        localStorage.setItem(STORAGE_KEY, nextId);
      }
    } catch {
      setPets([]);
      setActivePetIdState(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void refreshPets();
  }, [refreshPets]);

  const activePet = useMemo(
    () => pets.find((pet) => pet.id === activePetId) ?? null,
    [pets, activePetId],
  );

  const value = useMemo(
    () => ({
      pets,
      activePetId,
      activePet,
      loading,
      setActivePetId,
      refreshPets,
    }),
    [pets, activePetId, activePet, loading, setActivePetId, refreshPets],
  );

  return <ActivePetContext.Provider value={value}>{children}</ActivePetContext.Provider>;
}
