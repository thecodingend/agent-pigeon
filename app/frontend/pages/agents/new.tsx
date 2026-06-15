import { Head } from "@inertiajs/react";

import AppLayout from "@/layouts/AppLayout";
import { PageHeader } from "@/components/page-header";
import { AgentForm, type AgentFormValues, type ConnectorOption } from "./_form";

type Props = {
  agent: AgentFormValues;
  connectors: ConnectorOption[];
};

export default function NewAgent({ agent, connectors }: Props) {
  return (
    <>
      <Head title="New agent · Agent Pigeon" />

      <PageHeader title="New agent" meta="Configure the agent behavior." />

      <AgentForm
        agent={agent}
        connectors={connectors}
        method="post"
        action="/agents"
        submitLabel="Create agent"
      />
    </>
  );
}

NewAgent.layout = AppLayout;
