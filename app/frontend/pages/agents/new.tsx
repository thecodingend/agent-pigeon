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
  agent: AgentFormValues
  connectors: ConnectorGroups
  domain: { hostname: string; status: string; verified: boolean }
  email_options: EmailOption[]
  prompt_templates: PromptTemplate[]
}

export default function NewAgent({ agent, connectors, domain, email_options, prompt_templates }: Props) {
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
        emailOptions={email_options}
        promptTemplates={prompt_templates}
        method="post"
        action="/agents"
        submitLabel="Create agent"
      />
    </>
  )
}

NewAgent.layout = AppLayout
