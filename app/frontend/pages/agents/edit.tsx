import { Head } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { AgentForm, type AgentFormValues, type ConnectorOption } from "./_form"

type Props = {
  agent: AgentFormValues & { email_address?: string }
  connectors: ConnectorOption[]
}

export default function EditAgent({ agent, connectors }: Props) {
  return (
    <>
      <Head title={`Edit ${agent.name} · Agent Pigeon`} />

      <PageHeader
        title={agent.name}
        meta={
          agent.email_address ? (
            <span className="font-mono text-foreground">{agent.email_address}</span>
          ) : (
            <span>Edit settings</span>
          )
        }
      />

      <AgentForm
        agent={agent}
        connectors={connectors}
        method="patch"
        action={`/agents/${agent.id}`}
        submitLabel="Save changes"
      />
    </>
  )
}

EditAgent.layout = AppLayout
