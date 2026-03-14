import { SystemInfo } from "../types/system";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL;

export async function getSystemInfo(): Promise<SystemInfo> {
  const response = await fetch(`${API_BASE_URL}/api/system`, {
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error("Failed to fetch system info");
  }

  return response.json();
}
