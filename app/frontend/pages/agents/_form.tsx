import { Form, Link } from "@inertiajs/react"
import { useState, type ReactNode } from "react"

import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { cn } from "@/lib/utils"

export type ContextPolicy = "thread_history" | "last_message_only"

export type AgentFormValues = {
  id: number | null
  name: string
  local_part: string
  email_address?: string | null
  system_prompt: string
  status: "active" | "paused"
  inbox_policy: "open" | "allowlist"
  context_policy: ContextPolicy
  api_connector_ids: number[]
  web_connector_ids: number[]
  allowlist_patterns: string[]
}

export type PromptTemplate = {
  key: "support" | "ops" | "sales_research" | "custom"
  name: string
  system_prompt: string
}

export type EmailOption = {
  local_part: string
  email_address: string
  available: boolean
  current: boolean
}

export type ConnectorOption = {
  id: number
  kind: "api" | "web"
  name: string
  description: string
  summary: string
}

export type ConnectorGroups = {
  api: ConnectorOption[]
  web: ConnectorOption[]
}

type Props = {
  agent: AgentFormValues
  connectors: ConnectorGroups
  domain: { hostname: string }
  emailOptions: EmailOption[]
  promptTemplates: PromptTemplate[]
  method: "post" | "patch"
  action: string
  submitLabel: string
}

export function AgentForm({
  agent,
  connectors,
  domain,
  emailOptions,
  promptTemplates,
  method,
  action,
  submitLabel,
}: Props) {
  const firstAvailableEmail = emailOptions.find((option) => option.available)
  const initialLocalPart = agent.local_part || firstAvailableEmail?.local_part || ""
  const initialLocalPartMatchesOption = emailOptions.some((option) => option.local_part === initialLocalPart)
  const initialTemplate = promptTemplates.find((template) => template.system_prompt === agent.system_prompt)
    || (agent.system_prompt ? promptTemplates.find((template) => template.key === "custom") : promptTemplates[0])

  const [localPart, setLocalPart] = useState(initialLocalPart)
  const [emailMode, setEmailMode] = useState<"option" | "custom">(initialLocalPartMatchesOption ? "option" : "custom")
  const [customLocalPart, setCustomLocalPart] = useState(
    initialLocalPartMatchesOption ? "" : initialLocalPart,
  )
  const [prompt, setPrompt] = useState(agent.system_prompt || promptTemplates[0]?.system_prompt || "")
  const [templateKey, setTemplateKey] = useState(initialTemplate?.key || "custom")
  const [policy, setPolicy] = useState<"open" | "allowlist">(agent.inbox_policy)
  const [contextPolicy, setContextPolicy] = useState<ContextPolicy>(agent.context_policy)
  const [patterns, setPatterns] = useState<string[]>(
    agent.allowlist_patterns.length > 0 ? agent.allowlist_patterns : [""],
  )
  const [apiIds, setApiIds] = useState<number[]>(agent.api_connector_ids)
  const [webIds, setWebIds] = useState<number[]>(agent.web_connector_ids)

  const toolCount = apiIds.length + webIds.length
  const selectedEmail = `${localPart || "agent"}@${domain.hostname}`
  const selectedTemplateName = promptTemplates.find((template) => template.key === templateKey)?.name || "Custom"

  const selectTemplate = (template: PromptTemplate) => {
    setTemplateKey(template.key)
    setPrompt(template.system_prompt)
  }

  const selectEmail = (option: EmailOption) => {
    if (!option.available) return
    setEmailMode("option")
    setLocalPart(option.local_part)
    setCustomLocalPart("")
  }

  const selectCustomEmail = (value: string) => {
    const normalized = value.toLowerCase()
    setEmailMode("custom")
    setCustomLocalPart(normalized)
    setLocalPart(normalized)
  }

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
          <input type="hidden" name="agent[local_part]" value={localPart} />
          <input type="hidden" name="agent[status]" value={agent.status} />

          <Section label="1 Identity">
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

            <Field data-invalid={Boolean(errors.local_part)}>
              <FieldLabel>Email</FieldLabel>
              <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                {emailOptions.map((option) => (
                  <button
                    key={option.local_part}
                    type="button"
                    onClick={() => selectEmail(option)}
                    disabled={!option.available}
                    className={cn(
                      "flex min-h-16 flex-col gap-1 rounded-sm border border-border px-3 py-2 text-left transition-colors",
                      emailMode === "option" && option.local_part === localPart && "border-foreground bg-secondary",
                      option.available ? "hover:bg-secondary/60" : "cursor-not-allowed opacity-50",
                    )}
                  >
                    <span className="break-all font-mono text-sm text-foreground">{option.email_address}</span>
                    <span className="font-mono text-[10px] uppercase tracking-wider text-muted-foreground">
                      {option.current ? "current" : option.available ? "available" : "claimed"}
                    </span>
                  </button>
                ))}
              </div>

              <div className="grid grid-cols-[minmax(0,1fr)_auto] items-end gap-4 pt-3">
                <Input
                  value={emailMode === "custom" ? customLocalPart : ""}
                  onChange={(event) => selectCustomEmail(event.target.value)}
                  onFocus={() => {
                    setEmailMode("custom")
                    setLocalPart(customLocalPart)
                  }}
                  placeholder="custom"
                  className="font-mono lowercase"
                  autoComplete="off"
                />
                <div className="flex flex-col gap-1 pb-2">
                  <span className="text-xs uppercase tracking-wider text-muted-foreground">Selected</span>
                  <span className="break-all font-mono text-sm text-foreground">{selectedEmail}</span>
                </div>
              </div>
              <FieldError>{errors.local_part?.[0]}</FieldError>
            </Field>
          </Section>

          <Section label="2 Instructions">
            <Field data-invalid={Boolean(errors.system_prompt)}>
              <FieldLabel>Template</FieldLabel>
              <div className="grid grid-cols-1 gap-2 sm:grid-cols-4">
                {promptTemplates.map((template) => (
                  <button
                    key={template.key}
                    type="button"
                    onClick={() => selectTemplate(template)}
                    className={cn(
                      "min-h-12 rounded-sm border border-border px-3 py-2 text-left text-sm transition-colors hover:bg-secondary/60",
                      template.key === templateKey && "border-foreground bg-secondary",
                    )}
                  >
                    {template.name}
                  </button>
                ))}
              </div>
              <Textarea
                name="agent[system_prompt]"
                value={prompt}
                onChange={(event) => {
                  setPrompt(event.target.value)
                  setTemplateKey("custom")
                }}
                rows={10}
                placeholder="You are a careful, concise email assistant. Answer using the data sources attached to this agent. If you do not know, say so."
              />
              <FieldError>{errors.system_prompt?.[0]}</FieldError>
            </Field>
          </Section>

          <Section
            label="3 Tools"
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

            {connectors.api.length === 0 && connectors.web.length === 0 ? (
              <p className="text-sm text-muted-foreground">
                No sources in your library yet.{" "}
                <Link href="/data_sources" className="underline underline-offset-4 hover:text-foreground">
                  Build one
                </Link>{" "}
                and come back.
              </p>
            ) : (
              <div className="flex flex-col gap-8">
                <ToolGroup
                  title="API tools"
                  connectors={connectors.api}
                  isChecked={isChecked}
                  toggle={toggle}
                />
                <ToolGroup
                  title="Web tools"
                  connectors={connectors.web}
                  isChecked={isChecked}
                  toggle={toggle}
                />
              </div>
            )}
          </Section>

          <Section label="4 Context">
            <fieldset className="grid grid-cols-1 gap-3 sm:grid-cols-2">
              {(
                [
                  ["thread_history", "Thread history", "Use the prior emails in the conversation."],
                  ["last_message_only", "Last message only", "Reply using only the newest inbound email."],
                ] as const
              ).map(([value, label, helper]) => (
                <label
                  key={value}
                  className={cn(
                    "flex cursor-pointer items-start gap-3 rounded-sm border border-border px-3 py-3",
                    contextPolicy === value && "border-foreground bg-secondary",
                  )}
                >
                  <input
                    type="radio"
                    name="agent[context_policy]"
                    value={value}
                    checked={contextPolicy === value}
                    onChange={() => setContextPolicy(value)}
                    className="self-start accent-primary"
                  />
                  <span className="flex flex-col gap-1">
                    <span className="text-sm font-medium text-foreground">{label}</span>
                    <span className="text-xs text-muted-foreground">{helper}</span>
                  </span>
                </label>
              ))}
            </fieldset>
          </Section>

          <Section label="5 Access">
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
                    className="self-start accent-primary"
                  />
                  <span className="flex flex-col gap-0.5">
                    <span className="text-sm font-medium text-foreground">{label}</span>
                    <span className="text-xs text-muted-foreground">{helper}</span>
                  </span>
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

          <Section label="6 Review">
            <dl className="grid grid-cols-[120px_minmax(0,1fr)] gap-x-6 gap-y-3 text-sm">
              <dt className="text-muted-foreground">Email</dt>
              <dd className="break-all font-mono text-foreground">{selectedEmail}</dd>
              <dt className="text-muted-foreground">Template</dt>
              <dd className="text-foreground">{selectedTemplateName}</dd>
              <dt className="text-muted-foreground">Tools</dt>
              <dd className="text-foreground">{toolCount} selected</dd>
              <dt className="text-muted-foreground">Context</dt>
              <dd className="text-foreground">
                {contextPolicy === "thread_history" ? "Thread history" : "Last message only"}
              </dd>
              <dt className="text-muted-foreground">Access</dt>
              <dd className="text-foreground">{policy === "open" ? "Open" : "Allowlist"}</dd>
            </dl>

            <div className="flex items-center gap-3 pt-2">
              <Button type="submit" disabled={processing}>
                {processing ? "Saving..." : submitLabel}
              </Button>
              <Link href="/agents" className="text-sm text-muted-foreground underline underline-offset-4 hover:text-foreground">
                Cancel
              </Link>
            </div>
          </Section>
        </div>
      )}
    </Form>
  )
}

function ToolGroup({
  title,
  connectors,
  isChecked,
  toggle,
}: {
  title: string
  connectors: ConnectorOption[]
  isChecked: (connector: ConnectorOption) => boolean
  toggle: (connector: ConnectorOption) => void
}) {
  if (connectors.length === 0) return null

  return (
    <section className="flex flex-col">
      <h3 className="border-b border-border pb-2 text-sm font-semibold tracking-tight text-foreground">{title}</h3>
      <ul className="flex flex-col">
        {connectors.map((connector) => {
          const checked = isChecked(connector)
          const inputName = connector.kind === "api"
            ? "agent[api_connector_ids][]"
            : "agent[web_connector_ids][]"

          return (
            <li key={`${connector.kind}-${connector.id}`} className="border-b border-border last:border-b-0">
              <label className="grid cursor-pointer grid-cols-[24px_minmax(0,1fr)_minmax(120px,auto)] items-start gap-4 py-3">
                <input
                  type="checkbox"
                  checked={checked}
                  onChange={() => toggle(connector)}
                  className="self-start accent-primary"
                />
                {checked && <input type="hidden" name={inputName} value={connector.id} />}
                <span className="flex min-w-0 flex-col gap-0.5">
                  <span className="text-sm font-medium text-foreground">{connector.name}</span>
                  {connector.description && (
                    <span className="line-clamp-1 text-xs text-muted-foreground">{connector.description}</span>
                  )}
                </span>
                <span className="flex min-w-0 flex-col items-end gap-0.5">
                  <span className="font-mono text-[10px] uppercase tracking-wider text-muted-foreground">
                    {connector.kind}
                  </span>
                  <span className="line-clamp-1 text-right font-mono text-xs text-foreground">
                    {connector.summary}
                  </span>
                </span>
              </label>
            </li>
          )
        })}
      </ul>
    </section>
  )
}

function Section({
  label,
  aside,
  children,
}: {
  label: string
  aside?: ReactNode
  children: ReactNode
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
