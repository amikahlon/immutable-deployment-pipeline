import express, { Application, Request, Response } from "express";
import cors from "cors";
import systemRoutes from "./routes/system.routes";

const app: Application = express();

app.use(cors());
app.use(express.json());

app.get("/", (_req: Request, res: Response): void => {
  res.send("System Info API is running");
});

app.use("/api/system", systemRoutes);

export default app;
