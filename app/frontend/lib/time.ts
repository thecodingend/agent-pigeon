const DIVISIONS: { amount: number; name: Intl.RelativeTimeFormatUnit }[] = [
  { amount: 60, name: "seconds" },
  { amount: 60, name: "minutes" },
  { amount: 24, name: "hours" },
  { amount: 7, name: "days" },
  { amount: 4.34524, name: "weeks" },
  { amount: 12, name: "months" },
  { amount: Number.POSITIVE_INFINITY, name: "years" },
]

const formatter = new Intl.RelativeTimeFormat("en", { numeric: "auto" })

export function relativeTime(value: string | number | Date | null | undefined): string {
  if (!value) return "—"
  const date = value instanceof Date ? value : new Date(value)
  let duration = (date.getTime() - Date.now()) / 1000
  for (const division of DIVISIONS) {
    if (Math.abs(duration) < division.amount) {
      return formatter.format(Math.round(duration), division.name)
    }
    duration /= division.amount
  }
  return "—"
}

export function absoluteTime(value: string | number | Date | null | undefined): string {
  if (!value) return "—"
  const date = value instanceof Date ? value : new Date(value)
  return new Intl.DateTimeFormat("en", { dateStyle: "medium", timeStyle: "short" }).format(date)
}
