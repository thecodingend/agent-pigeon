import { Head, Link, usePage } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { buttonVariants } from "@/components/ui/button"
import { relativeTime } from "@/lib/time"
import type { SharedProps } from "@/types"

type AgentRow = {
  id: number
  name: string
  email_address: string | null
  status: "active" | "paused"
  inbox_policy: "open" | "allowlist"
  threads_count: number
  last_activity_at: string | null
}

type Props = { agents: AgentRow[] }

export default function AgentsIndex({ agents }: Props) {
  const { nav } = usePage<SharedProps>().props
  const hasConnection = nav?.email_connection_complete ?? false
  const targetHref = hasConnection ? "/agents/new" : "/email_connection"

  return (
    <>
      <Head title="Agents · Agent Pigeon" />

      <PageHeader
        title="Agents"
        meta={agents.length > 0 ? `${agents.length} configured` : undefined}
        action={
          agents.length > 0 ? (
            <Link href={targetHref} className={buttonVariants()}>
              New agent
            </Link>
          ) : null
        }
      />

      {agents.length === 0 ? <EmptyState hasConnection={hasConnection} /> : <AgentsTable agents={agents} />}
    </>
  )
}

function EmptyState({ hasConnection }: { hasConnection: boolean }) {
  return (
    <section className="flex flex-col gap-8 py-10">
      <div className="flex max-w-[44ch] flex-col gap-3">
        <p className="text-xl text-foreground">Your pigeons live here. None yet.</p>
        <p className="text-sm text-muted-foreground">
          An agent is an email address with a brain. Configure one, then forward, route, or write to it from any inbox.
        </p>
      </div>
      <div className="flex items-center gap-3">
        <Link href={hasConnection ? "/agents/new" : "/email_connection"} className={buttonVariants()}>
          {hasConnection ? "Create your first agent" : "Connect email first"}
        </Link>
        {!hasConnection && (
          <span className="text-sm text-muted-foreground">Set up the support address before agent behavior.</span>
        )}
      </div>
    </section>
  )
}

function AgentsTable({ agents }: { agents: AgentRow[] }) {
  return (
    <section className="flex flex-col">
      <div className="grid grid-cols-[1.4fr_2fr_0.8fr_0.6fr_0.9fr] gap-6 border-y border-border py-2 text-[11px] uppercase tracking-wider text-muted-foreground">
        <span>Name</span>
        <span>Email</span>
        <span>Status</span>
        <span>Threads</span>
        <span className="text-right">Last activity</span>
      </div>
      <ul className="flex flex-col">
        {agents.map((agent) => (
          <li key={agent.id} className="border-b border-border">
            <Link
              href={`/agents/${agent.id}`}
              className="grid grid-cols-[1.4fr_2fr_0.8fr_0.6fr_0.9fr] items-center gap-6 py-4 transition-colors hover:bg-secondary/40"
            >
              <span className="text-sm font-medium text-foreground">{agent.name}</span>
              <span className="truncate font-mono text-sm text-foreground">{agent.email_address ?? "—"}</span>
              <span className="text-sm text-muted-foreground">{agent.status}</span>
              <span className="font-mono text-sm text-foreground">{agent.threads_count}</span>
              <span className="text-right font-mono text-sm text-muted-foreground">
                {relativeTime(agent.last_activity_at)}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  )
}

AgentsIndex.layout = AppLayout
