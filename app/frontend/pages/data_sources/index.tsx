import { Form, Head, Link } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { buttonVariants } from "@/components/ui/button"

type ApiSource = {
  id: number
  name: string
  description: string
  http_method: "get" | "post"
  base_url: string
  agent_count: number
}

type WebSource = {
  id: number
  name: string
  description: string
  urls: string[]
  agent_count: number
}

type Props = { api_sources: ApiSource[]; web_sources: WebSource[] }

export default function DataSourcesIndex({ api_sources, web_sources }: Props) {
  const total = api_sources.length + web_sources.length

  return (
    <>
      <Head title="Data sources · Agent Pigeon" />

      <PageHeader
        title="Data sources"
        meta={total > 0 ? `${total} in your library` : "Reusable connectors. Attach them to any agent."}
        action={
          <div className="flex items-center gap-2">
            <Link href="/web_connectors/new" className={buttonVariants({ variant: "outline" })}>
              New web source
            </Link>
            <Link href="/api_connectors/new" className={buttonVariants()}>
              New API source
            </Link>
          </div>
        }
      />

      {total === 0 ? (
        <Empty />
      ) : (
        <div className="flex flex-col gap-12">
          {api_sources.length > 0 && (
            <Group title="API sources" count={api_sources.length}>
              {api_sources.map((s) => (
                <ApiRow key={s.id} source={s} />
              ))}
            </Group>
          )}
          {web_sources.length > 0 && (
            <Group title="Web sources" count={web_sources.length}>
              {web_sources.map((s) => (
                <WebRow key={s.id} source={s} />
              ))}
            </Group>
          )}
        </div>
      )}
    </>
  )
}

function Empty() {
  return (
    <section className="flex max-w-[44ch] flex-col gap-3 py-10">
      <p className="text-xl text-foreground">No sources yet.</p>
      <p className="text-sm text-muted-foreground">
        API sources let an agent reach your systems. Web sources let it read specific pages on the open web.
      </p>
    </section>
  )
}

function Group({ title, count, children }: { title: string; count: number; children: React.ReactNode }) {
  return (
    <section className="flex flex-col">
      <header className="flex items-baseline gap-3 border-b border-border pb-2">
        <h2 className="text-sm font-semibold tracking-tight text-foreground">{title}</h2>
        <span className="font-mono text-xs text-muted-foreground">{count}</span>
      </header>
      <ul className="flex flex-col">{children}</ul>
    </section>
  )
}

function ApiRow({ source }: { source: ApiSource }) {
  return (
    <li className="grid grid-cols-[1fr_2fr_0.7fr_auto] items-center gap-6 border-b border-border py-4">
      <div className="flex flex-col gap-1">
        <span className="text-sm font-medium text-foreground">{source.name}</span>
        {source.description && (
          <span className="text-xs text-muted-foreground line-clamp-1">{source.description}</span>
        )}
      </div>
      <span className="truncate font-mono text-xs text-foreground">
        {source.http_method.toUpperCase()} {source.base_url}
      </span>
      <span className="font-mono text-xs text-muted-foreground">
        {source.agent_count} agent{source.agent_count === 1 ? "" : "s"}
      </span>
      <DeleteSource action={`/api_connectors/${source.id}`} />
    </li>
  )
}

function WebRow({ source }: { source: WebSource }) {
  return (
    <li className="grid grid-cols-[1fr_2fr_0.7fr_auto] items-start gap-6 border-b border-border py-4">
      <div className="flex flex-col gap-1">
        <span className="text-sm font-medium text-foreground">{source.name}</span>
        {source.description && (
          <span className="text-xs text-muted-foreground line-clamp-1">{source.description}</span>
        )}
      </div>
      <div className="flex flex-col gap-0.5 font-mono text-xs text-foreground">
        {source.urls.slice(0, 3).map((u) => (
          <span key={u} className="truncate">{u}</span>
        ))}
        {source.urls.length > 3 && (
          <span className="text-muted-foreground">+{source.urls.length - 3} more</span>
        )}
      </div>
      <span className="font-mono text-xs text-muted-foreground">
        {source.agent_count} agent{source.agent_count === 1 ? "" : "s"}
      </span>
      <DeleteSource action={`/web_connectors/${source.id}`} />
    </li>
  )
}

function DeleteSource({ action }: { action: string }) {
  return (
    <Form method="delete" action={action}>
      {({ processing }) => (
        <button
          type="submit"
          disabled={processing}
          className="text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
          onClick={(e) => {
            if (!confirm("Remove this source from your library?")) e.preventDefault()
          }}
        >
          Remove
        </button>
      )}
    </Form>
  )
}

DataSourcesIndex.layout = AppLayout
