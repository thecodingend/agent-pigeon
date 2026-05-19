import type { ReactNode } from "react"

export default function AuthLayout({ children }: { children: ReactNode }) {
  return (
    <div className="grid min-h-svh lg:grid-cols-2">
      <div className="hidden flex-col justify-between bg-gradient-to-br from-primary/10 via-muted to-background p-10 lg:flex">
        <div className="text-lg font-semibold tracking-tight">Acme</div>
        <div className="flex flex-col gap-3">
          <p className="text-2xl font-semibold tracking-tight text-balance">
            Everything you need to ship your next product.
          </p>
          <p className="max-w-sm text-sm text-muted-foreground">
            Replace this panel with your brand and a single, concrete value
            proposition. Keep it short.
          </p>
        </div>
        <p className="text-xs text-muted-foreground">
          &copy; {new Date().getFullYear()} Acme, Inc.
        </p>
      </div>

      <div className="grid place-items-center bg-background p-6">{children}</div>
    </div>
  )
}
