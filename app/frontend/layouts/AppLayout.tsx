import { Link, usePage } from "@inertiajs/react"
import type { ReactNode } from "react"

import type { SharedProps } from "@/types"
import { cn } from "@/lib/utils"

type NavItem = {
  label: string
  href: string
  matches: (path: string) => boolean
}

const navItems: NavItem[] = [
  { label: "Agents", href: "/agents", matches: (p) => p === "/" || p.startsWith("/agents") },
  { label: "Data sources", href: "/data_sources", matches: (p) => p.startsWith("/data_sources") || p.startsWith("/api_connectors") || p.startsWith("/web_connectors") },
  { label: "Domain", href: "/domain", matches: (p) => p.startsWith("/domain") },
]

export default function AppLayout({ children }: { children: ReactNode }) {
  const page = usePage<SharedProps>()
  const { auth, nav, csrf_token } = page.props
  const path = page.url ?? "/"

  return (
    <div className="min-h-svh bg-background text-foreground font-sans">
      <div className="grid min-h-svh grid-cols-[240px_1fr]">
        <aside className="sticky top-0 flex h-svh flex-col justify-between border-r border-border px-6 py-8">
          <div className="flex flex-col gap-10">
            <Link href="/" className="group inline-flex items-baseline gap-2 text-foreground">
              <span className="text-[17px] font-semibold tracking-tight">Agent Pigeon</span>
              <span className="font-mono text-[10px] tracking-widest text-muted-foreground group-hover:text-foreground">
                v0
              </span>
            </Link>

            <nav className="flex flex-col gap-0.5">
              {navItems.map((item) => {
                const active = item.matches(path)
                const needsAttention = item.label === "Domain" && nav && !nav.domain_verified
                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      "flex items-center justify-between rounded-sm px-2 py-1.5 text-sm transition-colors",
                      active
                        ? "bg-secondary text-foreground"
                        : "text-muted-foreground hover:bg-secondary/60 hover:text-foreground"
                    )}
                  >
                    <span>{item.label}</span>
                    {needsAttention && (
                      <span className="font-mono text-[10px] uppercase tracking-wider text-primary">
                        setup
                      </span>
                    )}
                  </Link>
                )
              })}
            </nav>
          </div>

          <div className="flex flex-col gap-3">
            <div className="h-px bg-border" />
            <div className="flex flex-col gap-1">
              <span className="text-xs text-muted-foreground">Signed in as</span>
              <span className="truncate font-mono text-xs text-foreground" title={auth.user?.email}>
                {auth.user?.email ?? "—"}
              </span>
            </div>
            <form method="post" action="/users/sign_out">
              <input type="hidden" name="_method" value="delete" />
              <input type="hidden" name="authenticity_token" value={csrf_token} />
              <button
                type="submit"
                className="text-left text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
              >
                Sign out
              </button>
            </form>
          </div>
        </aside>

        <main className="px-12 py-12">
          <div className="mx-auto max-w-[760px]">{children}</div>
        </main>
      </div>
    </div>
  )
}
