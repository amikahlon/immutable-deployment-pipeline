import { Request, Response } from "express";
import systemService from "../services/system.service";

class SystemController {
  public getSystemInfo(_req: Request, res: Response): void {
    const systemInfo = systemService.getSystemInfo();
    res.status(200).json(systemInfo);
  }
}

export default new SystemController();
