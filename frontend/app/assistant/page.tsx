"use client";

import { apiUrl } from "@/lib/api";
import {
  AlertTriangle,
  ArrowUpRight,
  Bell,
  Bot,
  Paperclip,
  SendHorizonal,
  Settings,
  Trash2,
} from "lucide-react";
import { useCallback, useEffect, useRef, useState } from "react";

type ChatRole = "user" | "assistant";

type ChatMessage = {
  id: string;
  role: ChatRole;
  content: string;
  time: string;
};

const STORAGE_KEY = "pettrack-assistant-history";

const SUGGESTIONS = [
  "Kedim bugün çok iştahsız, ne yapmalıyım?",
  "Köpeklerde aşı sonrası halsizlik normal mi?",
  "Yavru kuşların beslenme sıklığı nedir?",
] as const;

const WELCOME =
  "Merhaba! Ben Pati Dostu. Evcil hayvanının sağlığı, beslenmesi veya uygulama kullanımı hakkında sorularını yazabilirsin.";

function nowLabel() {
  return new Date().toLocaleTimeString("tr-TR", { hour: "2-digit", minute: "2-digit" });
}

function createMessage(role: ChatRole, content: string): ChatMessage {
  return { id: `${role}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`, role, content, time: nowLabel() };
}

function loadHistory(): ChatMessage[] {
  if (typeof window === "undefined") return [createMessage("assistant", WELCOME)];
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [createMessage("assistant", WELCOME)];
    const parsed = JSON.parse(raw) as ChatMessage[];
    return parsed.length > 0 ? parsed : [createMessage("assistant", WELCOME)];
  } catch {
    return [createMessage("assistant", WELCOME)];
  }
}

export default function AssistantPage() {
  const [messages, setMessages] = useState<ChatMessage[]>(() => [createMessage("assistant", WELCOME)]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    setMessages(loadHistory());
  }, []);

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(messages));
  }, [messages]);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages, isLoading]);

  const sendMessage = useCallback(
    async (text: string) => {
      const prompt = text.trim();
      if (!prompt || isLoading) return;

      setError(null);
      const userMessage = createMessage("user", prompt);
      const nextMessages = [...messages, userMessage];
      setMessages(nextMessages);
      setInput("");
      setIsLoading(true);

      try {
        const history = nextMessages.slice(-10).map((m) => ({ role: m.role, content: m.content }));
        const res = await fetch(apiUrl("/api/chat"), {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ message: prompt, history }),
        });
        const data = (await res.json()) as { reply?: string; error?: string };

        if (!res.ok || !data.reply) {
          throw new Error(data.error ?? "Yanıt alınamadı.");
        }

        setMessages((prev) => [...prev, createMessage("assistant", data.reply!)]);
      } catch (err) {
        const msg = err instanceof Error ? err.message : "Şu an yanıt veremiyorum, lütfen tekrar dene.";
        setError(msg);
        setMessages((prev) => [...prev, createMessage("assistant", msg)]);
      } finally {
        setIsLoading(false);
        inputRef.current?.focus();
      }
    },
    [isLoading, messages],
  );

  function clearChat() {
    const fresh = [createMessage("assistant", WELCOME)];
    setMessages(fresh);
    setError(null);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(fresh));
  }

  return (
    <section className="mx-auto flex h-[calc(100dvh-5rem)] w-full max-w-7xl flex-col gap-4 md:h-[calc(100dvh-6rem)] lg:flex-row lg:gap-6">
      {/* Sol panel — öneriler */}
      <div className="flex shrink-0 flex-col gap-5 lg:w-[340px] xl:w-[380px]">
        <div className="flex items-start justify-between gap-3">
          <div>
            <h2 className="text-2xl font-bold tracking-tight text-slate-900 md:text-3xl">Pati Dostu Yapay Zeka</h2>
            <p className="mt-2 text-sm leading-relaxed text-slate-500 md:text-base">
              Dostunuzun semptomları hakkında detay yazarak analiz edin ve bakım tavsiyesi alın.
            </p>
          </div>
          <div className="hidden shrink-0 items-center gap-2 sm:flex">
            <button
              type="button"
              aria-label="Bildirimler"
              className="rounded-full border border-slate-200 bg-white p-2.5 text-slate-500 transition hover:bg-slate-50"
            >
              <Bell size={18} />
            </button>
            <button
              type="button"
              aria-label="Ayarlar"
              className="rounded-full border border-slate-200 bg-white p-2.5 text-slate-500 transition hover:bg-slate-50"
            >
              <Settings size={18} />
            </button>
          </div>
        </div>

        <div className="space-y-3">
          {SUGGESTIONS.map((text) => (
            <button
              key={text}
              type="button"
              disabled={isLoading}
              onClick={() => void sendMessage(text)}
              className="group flex w-full items-start gap-3 rounded-2xl border border-slate-200 bg-white p-4 text-left shadow-sm transition hover:border-teal-200 hover:shadow-md disabled:opacity-60"
            >
              <span className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-teal-50 text-teal-700">
                <ArrowUpRight size={16} />
              </span>
              <span className="text-sm leading-relaxed text-slate-700 group-hover:text-slate-900">{text}</span>
            </button>
          ))}
        </div>

        <div className="mt-auto hidden rounded-2xl border border-amber-200 bg-amber-50/80 p-4 lg:flex">
          <div className="flex gap-3">
            <AlertTriangle className="mt-0.5 shrink-0 text-amber-600" size={18} />
            <p className="text-xs leading-relaxed text-amber-900/90">
              Bu yapay zeka tavsiyeleri profesyonel teşhis ile yer değiştiremez. Acil durumlarda lütfen en yakın
              veteriner kliniğine başvurun.
            </p>
          </div>
        </div>
      </div>

      {/* Sağ panel — sohbet */}
      <article className="flex min-h-0 flex-1 flex-col overflow-hidden rounded-[2rem] border border-slate-200 bg-white shadow-sm">
        <header className="flex items-center justify-between border-b border-slate-100 px-5 py-4">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-full bg-teal-700 text-white shadow-md shadow-teal-700/20">
              <Bot size={22} />
            </div>
            <div>
              <p className="font-semibold text-slate-900">Pati Dostu</p>
              <p className="flex items-center gap-1.5 text-xs text-emerald-600">
                <span className="inline-block h-2 w-2 rounded-full bg-emerald-500" />
                Çevrimiçi
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={clearChat}
            aria-label="Sohbeti temizle"
            className="rounded-xl p-2 text-slate-400 transition hover:bg-slate-100 hover:text-rose-500"
          >
            <Trash2 size={18} />
          </button>
        </header>

        <div ref={scrollRef} className="min-h-0 flex-1 space-y-4 overflow-y-auto px-4 py-5 sm:px-6">
          {messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex flex-col gap-1 ${msg.role === "user" ? "items-end" : "items-start"}`}
            >
              <div
                className={`max-w-[85%] rounded-2xl px-4 py-3 text-sm leading-relaxed sm:max-w-[75%] ${
                  msg.role === "user"
                    ? "rounded-br-md bg-teal-800 text-white"
                    : "rounded-bl-md bg-slate-100 text-slate-800"
                }`}
              >
                {msg.content}
              </div>
              <span className="px-1 text-[11px] text-slate-400">{msg.time}</span>
            </div>
          ))}

          {isLoading ? (
            <div className="flex items-start gap-2">
              <div className="rounded-2xl rounded-bl-md bg-slate-100 px-4 py-3">
                <div className="flex items-center gap-2 text-sm text-slate-500">
                  <Bot size={16} className="animate-pulse text-teal-600" />
                  Pati Dostu yazıyor...
                </div>
              </div>
            </div>
          ) : null}
        </div>

        {error ? (
          <p className="border-t border-rose-100 bg-rose-50 px-5 py-2 text-xs text-rose-700">{error}</p>
        ) : null}

        <footer className="border-t border-slate-100 p-4 sm:p-5">
          <form
            className="flex items-center gap-2 rounded-full border border-slate-200 bg-slate-50 px-3 py-2"
            onSubmit={(e) => {
              e.preventDefault();
              void sendMessage(input);
            }}
          >
            <button
              type="button"
              aria-label="Dosya ekle"
              className="rounded-full p-2 text-slate-400 transition hover:bg-white hover:text-slate-600"
              disabled
              title="Yakında"
            >
              <Paperclip size={18} />
            </button>
            <input
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Mesajınızı yazın..."
              disabled={isLoading}
              className="min-w-0 flex-1 bg-transparent px-1 py-2 text-sm text-slate-800 outline-none placeholder:text-slate-400"
            />
            <button
              type="submit"
              disabled={isLoading || !input.trim()}
              aria-label="Gönder"
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-teal-700 text-white transition hover:bg-teal-800 disabled:cursor-not-allowed disabled:opacity-50"
            >
              <SendHorizonal size={18} />
            </button>
          </form>
        </footer>
      </article>

      <div className="rounded-2xl border border-amber-200 bg-amber-50/80 p-4 lg:hidden">
        <div className="flex gap-3">
          <AlertTriangle className="mt-0.5 shrink-0 text-amber-600" size={18} />
          <p className="text-xs leading-relaxed text-amber-900/90">
            Bu yapay zeka tavsiyeleri profesyonel teşhis ile yer değiştiremez. Acil durumlarda lütfen en yakın
            veteriner kliniğine başvurun.
          </p>
        </div>
      </div>
    </section>
  );
}
