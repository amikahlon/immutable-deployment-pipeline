import { SystemInfo } from "../types/system";
import SystemInfoCard from "./SystemInfoCard";

interface SystemInfoGridProps {
  systemInfo: SystemInfo;
}

function formatMemoryMB(bytes: number): string {
  const mb = bytes / 1024 / 1024;
  return `${mb.toFixed(2)} MB`;
}

function formatUptime(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainingSeconds = Math.floor(seconds % 60);

  return `${hours}h ${minutes}m ${remainingSeconds}s`;
}

function formatMemoryPercent(freeMemory: number, totalMemory: number): string {
  const percent = (freeMemory / totalMemory) * 100;
  return `${percent.toFixed(2)}%`;
}

export default function SystemInfoGrid({ systemInfo }: SystemInfoGridProps) {
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
      <SystemInfoCard title="Hostname" value={systemInfo.hostname} />
      <SystemInfoCard title="Platform" value={systemInfo.platform} />
      <SystemInfoCard title="Architecture" value={systemInfo.architecture} />
      <SystemInfoCard title="Uptime" value={formatUptime(systemInfo.uptime)} />
      <SystemInfoCard
        title="Total Memory"
        value={formatMemoryMB(systemInfo.totalMemory)}
      />
      <SystemInfoCard
        title="Free Memory"
        value={formatMemoryMB(systemInfo.freeMemory)}
      />
      <SystemInfoCard
        title="Free Memory %"
        value={formatMemoryPercent(
          systemInfo.freeMemory,
          systemInfo.totalMemory,
        )}
      />
      <SystemInfoCard title="CPU Count" value={String(systemInfo.cpuCount)} />
    </div>
  );
}
