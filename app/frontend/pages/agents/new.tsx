import { Head } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { AgentForm, type AgentFormValues, type ConnectorOption } from "./_form"

type Props = {
  agent: AgentFormValues
  connectors: ConnectorOption[]
  domain: { hostname: string; status: string; verified: boolean }
}

export default function NewAgent({ agent, connectors, domain }: Props) {
  return (
    <>
      <Head title="New agent · Agent Pigeon" />

      <PageHeader
        title="New agent"
        meta={
          <span>
            Address will be on <span className="font-mono text-foreground">{domain.hostname}</span>
          </span>
        }
      />

      <AgentForm
        agent={agent}
        connectors={connectors}
        domain={domain}
        method="post"
        action="/agents"
        submitLabel="Create agent"
      />
    </>
  )
}

NewAgent.layout = AppLayout
