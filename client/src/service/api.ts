import { SystemInfo } from "../types/system";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:4000";

export async function getSystemInfo(): Promise<SystemInfo> {
  const res = await fetch(`${API_BASE_URL}/api/system`, {
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error("Failed to fetch system info");
  }

  return res.json();
}
