import { Head } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import {
  AgentForm,
  type AgentFormValues,
  type ConnectorGroups,
  type EmailOption,
  type PromptTemplate,
} from "./_form"

type Props = {
  agent: AgentFormValues & { email_address?: string }
  connectors: ConnectorGroups
  domain: { hostname: string; status: string; verified: boolean }
  email_options: EmailOption[]
  prompt_templates: PromptTemplate[]
}

export default function EditAgent({ agent, connectors, domain, email_options, prompt_templates }: Props) {
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
        domain={domain}
        emailOptions={email_options}
        promptTemplates={prompt_templates}
        method="patch"
        action={`/agents/${agent.id}`}
        submitLabel="Save changes"
      />
    </>
  )
}

EditAgent.layout = AppLayout
