import { Form, Head, Link } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"

type Props = {
  api_connector: {
    name: string
    description: string
    base_url: string
    http_method: "get" | "post"
    auth_type: "bearer"
    request_example_text: string
    response_example_text: string
    query_schema_text: string
    response_schema_text: string
    timeout_seconds: number
    max_response_bytes: number
    enabled: boolean
  }
}

export default function NewApiSource({ api_connector }: Props) {
  return (
    <>
      <Head title="New API source · Agent Pigeon" />

      <PageHeader
        title="New API source"
        meta={
          <span>
            <Link href="/data_sources" className="underline underline-offset-4 hover:text-foreground">
              ← back to library
            </Link>
          </span>
        }
      />

      <Form method="post" action="/api_connectors">
        {({ errors, processing }) => (
          <div className="flex flex-col gap-10">
            <section className="flex flex-col gap-5">
              <Field data-invalid={Boolean(errors.name)}>
                <FieldLabel>Name</FieldLabel>
                <Input name="api_connector[name]" defaultValue={api_connector.name} placeholder="Stripe customers" autoFocus required />
                <FieldError>{errors.name?.[0]}</FieldError>
              </Field>

              <Field data-invalid={Boolean(errors.description)}>
                <FieldLabel>Description</FieldLabel>
                <Textarea
                  name="api_connector[description]"
                  defaultValue={api_connector.description}
                  placeholder="What this API is about, written for an LLM to read."
                  rows={3}
                />
                <FieldError>{errors.description?.[0]}</FieldError>
              </Field>
            </section>

            <SectionDivider label="Request" />

            <section className="flex flex-col gap-5">
              <div className="grid grid-cols-[140px_1fr] gap-4">
                <Field data-invalid={Boolean(errors.http_method)}>
                  <FieldLabel>Method</FieldLabel>
                  <fieldset className="flex gap-2 pt-1">
                    {(["get", "post"] as const).map((m) => (
                      <label
                        key={m}
                        className="flex items-center gap-2 font-mono text-xs uppercase tracking-wider has-[input:checked]:text-foreground text-muted-foreground"
                      >
                        <input
                          type="radio"
                          name="api_connector[http_method]"
                          value={m}
                          defaultChecked={api_connector.http_method === m}
                          disabled={m === "post"}
                          className="accent-primary"
                        />
                        {m}
                        {m === "post" && <span className="text-[10px] normal-case">(soon)</span>}
                      </label>
                    ))}
                  </fieldset>
                </Field>

                <Field data-invalid={Boolean(errors.base_url)}>
                  <FieldLabel>Base URL</FieldLabel>
                  <Input
                    name="api_connector[base_url]"
                    defaultValue={api_connector.base_url}
                    placeholder="https://api.example.com/v1/customers"
                    className="font-mono"
                    required
                  />
                  <FieldError>{errors.base_url?.[0]}</FieldError>
                </Field>
              </div>

              <Field data-invalid={Boolean(errors.auth_token)}>
                <FieldLabel>Bearer token</FieldLabel>
                <Input
                  name="api_connector[auth_token]"
                  type="password"
                  placeholder="sk_live_..."
                  autoComplete="off"
                  className="font-mono"
                />
                <FieldError>{errors.auth_token?.[0]}</FieldError>
              </Field>

              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <Field data-invalid={Boolean(errors.timeout_seconds)}>
                  <FieldLabel>Timeout seconds</FieldLabel>
                  <Input
                    name="api_connector[timeout_seconds]"
                    type="number"
                    min={1}
                    max={30}
                    defaultValue={api_connector.timeout_seconds}
                    className="font-mono"
                  />
                  <FieldError>{errors.timeout_seconds?.[0]}</FieldError>
                </Field>

                <Field data-invalid={Boolean(errors.max_response_bytes)}>
                  <FieldLabel>Max response bytes</FieldLabel>
                  <Input
                    name="api_connector[max_response_bytes]"
                    type="number"
                    min={1}
                    defaultValue={api_connector.max_response_bytes}
                    className="font-mono"
                  />
                  <FieldError>{errors.max_response_bytes?.[0]}</FieldError>
                </Field>
              </div>

              <label className="flex items-center gap-2 text-sm text-foreground">
                <input type="hidden" name="api_connector[enabled]" value="0" />
                <input
                  type="checkbox"
                  name="api_connector[enabled]"
                  value="1"
                  defaultChecked={api_connector.enabled}
                  className="accent-primary"
                />
                Enabled
              </label>

              <Field data-invalid={Boolean(errors.query_schema)}>
                <FieldLabel>Query schema (JSON)</FieldLabel>
                <Textarea
                  name="api_connector[query_schema_text]"
                  defaultValue={api_connector.query_schema_text}
                  placeholder='{"type":"object","properties":{"query":{"type":"string"}},"required":["query"]}'
                  rows={5}
                  className="font-mono text-xs"
                />
                <FieldError>{errors.query_schema?.[0]}</FieldError>
              </Field>
            </section>

            <SectionDivider label="Response" />

            <section className="flex flex-col gap-5">
              <Field data-invalid={Boolean(errors.response_schema)}>
                <FieldLabel>Response schema (JSON)</FieldLabel>
                <Textarea
                  name="api_connector[response_schema_text]"
                  defaultValue={api_connector.response_schema_text}
                  placeholder='{"type":"object","properties":{"id":{"type":"string"}},"required":["id"]}'
                  rows={8}
                  className="font-mono text-xs"
                />
                <FieldError>{errors.response_schema?.[0]}</FieldError>
              </Field>
            </section>

            <div className="flex items-center gap-3 pt-4">
              <Button type="submit" disabled={processing}>
                {processing ? "Adding..." : "Add to library"}
              </Button>
              <Link href="/data_sources" className="text-sm text-muted-foreground underline underline-offset-4 hover:text-foreground">
                Cancel
              </Link>
            </div>
          </div>
        )}
      </Form>
    </>
  )
}

function SectionDivider({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-4">
      <span className="font-mono text-[11px] uppercase tracking-wider text-muted-foreground">{label}</span>
      <div className="h-px flex-1 bg-border" />
    </div>
  )
}

NewApiSource.layout = AppLayout
