import { Router } from "express";
import systemController from "../controllers/system.controller";

const router: Router = Router();

router.get("/", (req, res) => systemController.getSystemInfo(req, res));

export default router;
