import "./globals.css";
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "System Info Dashboard",
  description: "Next.js client for System Info API",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
