import SystemInfoGrid from "../components/SystemInfoGrid";
import { getSystemInfo } from "../service/api";

export default async function Home() {
  const systemInfo = await getSystemInfo();

  return (
    <main className="min-h-screen bg-gray-50 px-6 py-10">
      <div className="mx-auto max-w-6xl">
        <div className="mb-8">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-blue-600">
            Server Instance Information
          </p>
          <h1 className="mt-2 text-4xl font-bold text-gray-900">
            System Info API
          </h1>
          <p className="mt-3 max-w-2xl text-gray-600">
            This page displays live system information returned by the Node.js
            server.
          </p>
          <h1>By Ami Kahlon</h1>
        </div>

        <SystemInfoGrid systemInfo={systemInfo} />
      </div>
    </main>
  );
}
