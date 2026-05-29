import { Head, Link } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { buttonVariants } from "@/components/ui/button"
import { relativeTime } from "@/lib/time"

type Agent = {
  id: number
  name: string
  email_address: string
  status: "active" | "paused"
  inbox_policy: "open" | "allowlist"
  threads_count: number
  last_activity_at: string | null
}

type Thread = {
  id: number
  subject: string
  last_sender: string | null
  snippet: string
  last_activity_at: string
  message_count: number
}

type Props = { agent: Agent; threads: Thread[] }

export default function AgentShow({ agent, threads }: Props) {
  return (
    <>
      <Head title={`${agent.name} · Agent Pigeon`} />

      <PageHeader
        title={agent.name}
        meta={
          <div className="flex items-center gap-3">
            <span className="font-mono text-sm text-foreground">{agent.email_address}</span>
            {agent.status === "paused" && (
              <>
                <span className="text-muted-foreground">·</span>
                <span className="text-sm text-muted-foreground">paused</span>
              </>
            )}
          </div>
        }
        action={
          <Link href={`/agents/${agent.id}/edit`} className={buttonVariants({ variant: "outline" })}>
            Edit settings
          </Link>
        }
      />

      {threads.length === 0 ? <EmptyThreads agent={agent} /> : <ThreadsTable agent={agent} threads={threads} />}
    </>
  )
}

function EmptyThreads({ agent }: { agent: Agent }) {
  return (
    <section className="flex max-w-[44ch] flex-col gap-3 py-10">
      <p className="text-xl text-foreground">Nothing yet.</p>
      <p className="text-sm text-muted-foreground">
        Send a note to <span className="font-mono text-foreground select-all">{agent.email_address}</span> to start a thread. We&rsquo;ll log it here.
      </p>
    </section>
  )
}

function ThreadsTable({ agent, threads }: { agent: Agent; threads: Thread[] }) {
  return (
    <section className="flex flex-col">
      <div className="grid grid-cols-[1.4fr_1.2fr_2fr_0.7fr] gap-6 border-y border-border py-2 text-[11px] uppercase tracking-wider text-muted-foreground">
        <span>Subject</span>
        <span>From</span>
        <span>Latest</span>
        <span className="text-right">Updated</span>
      </div>
      <ul className="flex flex-col">
        {threads.map((thread) => (
          <li key={thread.id} className="border-b border-border">
            <Link
              href={`/agents/${agent.id}/threads/${thread.id}`}
              className="grid grid-cols-[1.4fr_1.2fr_2fr_0.7fr] items-start gap-6 py-4 transition-colors hover:bg-secondary/40"
            >
              <span className="text-sm font-medium text-foreground line-clamp-1">{thread.subject}</span>
              <span className="truncate font-mono text-xs text-muted-foreground">{thread.last_sender ?? "—"}</span>
              <span className="text-xs text-muted-foreground line-clamp-1">{thread.snippet}</span>
              <span className="text-right font-mono text-xs text-muted-foreground">
                {relativeTime(thread.last_activity_at)}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  )
}

AgentShow.layout = AppLayout
