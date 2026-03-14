interface SystemInfoCardProps {
  title: string;
  value: string;
}

export default function SystemInfoCard({ title, value }: SystemInfoCardProps) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md">
      <p className="text-sm font-medium text-gray-500">{title}</p>
      <p className="mt-2 text-xl font-semibold text-gray-900">{value}</p>
    </div>
  );
}
