import app from "./app";

const PORT: number = 4000;

app.listen(PORT, (): void => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
