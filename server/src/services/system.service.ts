import os from "os";
import { SystemInfo } from "../types/system.types";

class SystemService {
  public getSystemInfo(): SystemInfo {
    return {
      hostname: os.hostname(),
      platform: os.platform(),
      architecture: os.arch(),
      uptime: os.uptime(),
      totalMemory: os.totalmem(),
      freeMemory: os.freemem(),
      cpuCount: os.cpus().length,
    };
  }
}

export default new SystemService();
