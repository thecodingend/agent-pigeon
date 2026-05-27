import { Head, Link } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { absoluteTime } from "@/lib/time"

type Agent = { id: number; name: string; email_address: string }

type Thread = {
  id: number
  subject: string
  participants: string[]
  last_activity_at: string
}

type Message = {
  id: number
  direction: "inbound" | "outbound"
  from_email: string
  to_emails: string[]
  subject: string
  text: string | null
  received_at: string | null
  delivered_at: string | null
  created_at: string
}

type Props = { agent: Agent; thread: Thread; messages: Message[] }

export default function ThreadShow({ agent, thread, messages }: Props) {
  return (
    <>
      <Head title={`${thread.subject} · ${agent.name}`} />

      <PageHeader
        title={thread.subject}
        meta={
          <div className="flex flex-col gap-1">
            <span className="font-mono text-xs text-muted-foreground">
              {thread.participants.join(" · ")}
            </span>
            <Link
              href={`/agents/${agent.id}`}
              className="text-xs underline underline-offset-4 hover:text-foreground"
            >
              ← {agent.name}
            </Link>
          </div>
        }
      />

      <section className="flex flex-col">
        {messages.map((message) => (
          <article key={message.id} className="border-b border-border py-6 last:border-b-0">
            <header className="grid grid-cols-[80px_1fr_auto] items-baseline gap-4 pb-3 font-mono text-xs">
              <span
                className={
                  message.direction === "inbound"
                    ? "text-foreground"
                    : "text-primary"
                }
              >
                {message.direction === "inbound" ? "→ inbound" : "← outbound"}
              </span>
              <div className="flex flex-col gap-0.5 text-muted-foreground">
                <span>
                  <span className="text-foreground">{message.from_email}</span>{" "}
                  →{" "}
                  <span className="text-foreground">{message.to_emails.join(", ")}</span>
                </span>
              </div>
              <span className="text-muted-foreground">
                {absoluteTime(message.received_at ?? message.delivered_at ?? message.created_at)}
              </span>
            </header>

            <div className="whitespace-pre-wrap text-sm leading-relaxed text-foreground">
              {message.text || <span className="text-muted-foreground">(no body)</span>}
            </div>
          </article>
        ))}
      </section>
    </>
  )
}

ThreadShow.layout = AppLayout
