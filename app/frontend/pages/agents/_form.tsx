import { Form, Link } from "@inertiajs/react"
import { useState } from "react"

import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"

export type AgentFormValues = {
  id: number | null
  name: string
  local_part: string
  system_prompt: string
  status: "active" | "paused"
  inbox_policy: "open" | "allowlist"
  api_connector_ids: number[]
  web_connector_ids: number[]
  allowlist_patterns: string[]
}

export type ConnectorOption = {
  id: number
  kind: "api" | "web"
  name: string
  description: string
  summary: string
}

type Props = {
  agent: AgentFormValues
  connectors: ConnectorOption[]
  domain: { hostname: string }
  method: "post" | "patch"
  action: string
  submitLabel: string
}

export function AgentForm({ agent, connectors, domain, method, action, submitLabel }: Props) {
  const [localPart, setLocalPart] = useState(agent.local_part)
  const [policy, setPolicy] = useState<"open" | "allowlist">(agent.inbox_policy)
  const [patterns, setPatterns] = useState<string[]>(
    agent.allowlist_patterns.length > 0 ? agent.allowlist_patterns : [""],
  )
  const [apiIds, setApiIds] = useState<number[]>(agent.api_connector_ids)
  const [webIds, setWebIds] = useState<number[]>(agent.web_connector_ids)

  const toggle = (connector: ConnectorOption) => {
    if (connector.kind === "api") {
      setApiIds((prev) => (prev.includes(connector.id) ? prev.filter((x) => x !== connector.id) : [...prev, connector.id]))
    } else {
      setWebIds((prev) => (prev.includes(connector.id) ? prev.filter((x) => x !== connector.id) : [...prev, connector.id]))
    }
  }

  const isChecked = (connector: ConnectorOption) =>
    connector.kind === "api" ? apiIds.includes(connector.id) : webIds.includes(connector.id)

  return (
    <Form method={method} action={action}>
      {({ errors, processing }) => (
        <div className="flex flex-col gap-10">
          <Section label="Identity">
            <Field data-invalid={Boolean(errors.name)}>
              <FieldLabel>Name</FieldLabel>
              <Input
                name="agent[name]"
                defaultValue={agent.name}
                placeholder="Support"
                autoFocus
                required
              />
              <FieldError>{errors.name?.[0]}</FieldError>
            </Field>

            <div className="grid grid-cols-[1fr_1.4fr] items-end gap-4">
              <Field data-invalid={Boolean(errors.local_part)}>
                <FieldLabel>Local part</FieldLabel>
                <Input
                  name="agent[local_part]"
                  defaultValue={agent.local_part}
                  onChange={(e) => setLocalPart(e.target.value.toLowerCase())}
                  placeholder="support"
                  className="font-mono lowercase"
                  required
                />
                <FieldError>{errors.local_part?.[0]}</FieldError>
              </Field>
              <div className="flex flex-col gap-1 pb-2">
                <span className="text-xs uppercase tracking-wider text-muted-foreground">Email</span>
                <span className="font-mono text-sm text-foreground break-all">
                  {(localPart || "support").toLowerCase()}@{domain.hostname}
                </span>
              </div>
            </div>
          </Section>

          <Section label="Instructions">
            <Field data-invalid={Boolean(errors.system_prompt)}>
              <FieldLabel>System prompt</FieldLabel>
              <Textarea
                name="agent[system_prompt]"
                defaultValue={agent.system_prompt}
                rows={10}
                placeholder="You are a careful, concise email assistant. Answer using the data sources attached to this agent. If you don't know, say so."
              />
              <FieldError>{errors.system_prompt?.[0]}</FieldError>
            </Field>
          </Section>

          <Section
            label="Data sources"
            aside={
              <div className="flex items-center gap-3 text-xs">
                <Link href="/api_connectors/new" className="text-muted-foreground underline underline-offset-4 hover:text-foreground">
                  + API
                </Link>
                <Link href="/web_connectors/new" className="text-muted-foreground underline underline-offset-4 hover:text-foreground">
                  + Web
                </Link>
              </div>
            }
          >
            <input type="hidden" name="agent[api_connector_ids][]" value="" />
            <input type="hidden" name="agent[web_connector_ids][]" value="" />
            {connectors.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                No sources in your library yet.{" "}
                <Link href="/data_sources" className="underline underline-offset-4 hover:text-foreground">
                  Build one
                </Link>{" "}
                and come back.
              </p>
            ) : (
              <ul className="flex flex-col">
                {connectors.map((connector) => {
                  const checked = isChecked(connector)
                  const inputName = connector.kind === "api"
                    ? "agent[api_connector_ids][]"
                    : "agent[web_connector_ids][]"
                  return (
                    <li key={`${connector.kind}-${connector.id}`} className="border-b border-border last:border-b-0">
                      <label className="grid cursor-pointer grid-cols-[24px_1fr_auto] items-start gap-4 py-3">
                        <input
                          type="checkbox"
                          checked={checked}
                          onChange={() => toggle(connector)}
                          className="mt-1 size-4 accent-primary"
                        />
                        {checked && <input type="hidden" name={inputName} value={connector.id} />}
                        <div className="flex flex-col gap-0.5">
                          <span className="text-sm font-medium text-foreground">{connector.name}</span>
                          {connector.description && (
                            <span className="text-xs text-muted-foreground line-clamp-1">{connector.description}</span>
                          )}
                        </div>
                        <div className="flex flex-col items-end gap-0.5">
                          <span className="font-mono text-[10px] uppercase tracking-wider text-muted-foreground">
                            {connector.kind}
                          </span>
                          <span className="font-mono text-xs text-foreground line-clamp-1 text-right">
                            {connector.summary}
                          </span>
                        </div>
                      </label>
                    </li>
                  )
                })}
              </ul>
            )}
          </Section>

          <Section label="Who can email">
            <fieldset className="flex flex-col gap-3">
              {(
                [
                  ["open", "Open", "Anyone with the address can reach this agent."],
                  ["allowlist", "Allowlist", "Only the addresses and @domain.com patterns listed below."],
                ] as const
              ).map(([value, label, helper]) => (
                <label key={value} className="flex cursor-pointer items-start gap-3">
                  <input
                    type="radio"
                    name="agent[inbox_policy]"
                    value={value}
                    checked={policy === value}
                    onChange={() => setPolicy(value)}
                    className="mt-1 accent-primary"
                  />
                  <div className="flex flex-col gap-0.5">
                    <span className="text-sm font-medium text-foreground">{label}</span>
                    <span className="text-xs text-muted-foreground">{helper}</span>
                  </div>
                </label>
              ))}
            </fieldset>

            {policy === "allowlist" && (
              <div className="flex flex-col gap-3 border-t border-border pt-5">
                <p className="text-xs text-muted-foreground">
                  One per row. Either a full address (<span className="font-mono">ada@example.com</span>) or{" "}
                  <span className="font-mono">@example.com</span> to allow the whole domain.
                </p>
                <ul className="flex flex-col gap-2">
                  {patterns.map((pattern, idx) => (
                    <li key={idx} className="flex items-center gap-2">
                      <Input
                        name="agent[allowlist_patterns][]"
                        defaultValue={pattern}
                        placeholder="@example.com"
                        className="font-mono text-xs"
                      />
                      <button
                        type="button"
                        onClick={() => setPatterns((prev) => prev.filter((_, i) => i !== idx))}
                        className="text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
                        disabled={patterns.length === 1}
                      >
                        Remove
                      </button>
                    </li>
                  ))}
                </ul>
                <div>
                  <button
                    type="button"
                    onClick={() => setPatterns((prev) => [...prev, ""])}
                    className="text-sm text-foreground underline underline-offset-4"
                  >
                    + Add pattern
                  </button>
                </div>
                <FieldError>{errors.allowlist_entries?.[0]}</FieldError>
              </div>
            )}
          </Section>

          <div className="flex items-center gap-3 pt-2">
            <Button type="submit" disabled={processing}>
              {processing ? "Saving..." : submitLabel}
            </Button>
            <Link href="/agents" className="text-sm text-muted-foreground underline underline-offset-4 hover:text-foreground">
              Cancel
            </Link>
          </div>
        </div>
      )}
    </Form>
  )
}

function Section({
  label,
  aside,
  children,
}: {
  label: string
  aside?: React.ReactNode
  children: React.ReactNode
}) {
  return (
    <section className="flex flex-col gap-5">
      <header className="flex items-center justify-between border-b border-border pb-2">
        <span className="font-mono text-[11px] uppercase tracking-wider text-muted-foreground">{label}</span>
        {aside}
      </header>
      {children}
    </section>
  )
}
