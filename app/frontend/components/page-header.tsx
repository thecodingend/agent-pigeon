import type { ReactNode } from "react"

export function PageHeader({
  title,
  meta,
  action,
}: {
  title: ReactNode
  meta?: ReactNode
  action?: ReactNode
}) {
  return (
    <header className="flex flex-col gap-6 pb-8">
      <div className="flex items-end justify-between gap-6">
        <div className="flex flex-col gap-2">
          <h1 className="text-3xl font-semibold tracking-tight text-foreground">{title}</h1>
          {meta ? <div className="text-sm text-muted-foreground">{meta}</div> : null}
        </div>
        {action ? <div className="shrink-0">{action}</div> : null}
      </div>
      <div className="h-px w-full bg-border" />
    </header>
  )
}
