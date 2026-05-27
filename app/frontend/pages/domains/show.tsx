import { Form, Head } from "@inertiajs/react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { absoluteTime } from "@/lib/time"

type DnsRecord = {
  type: string
  name: string
  value: string
  priority?: number
  status: "pending" | "verified" | "failed"
}

type Domain = {
  hostname: string
  status: "pending" | "verifying" | "verified" | "failed"
  verified: boolean
  verified_at: string | null
  dns_records: DnsRecord[]
  created_at: string
}

type Props = { domain: Domain | null }

export default function DomainShow({ domain }: Props) {
  return (
    <>
      <Head title="Domain · Agent Pigeon" />

      <PageHeader
        title="Domain"
        meta={
          domain
            ? domain.verified
              ? "Verified. Agents can be created and reached."
              : "Add the DNS records below at your DNS provider, then re-check."
            : "One verified domain. Every agent gets an address on it."
        }
      />

      {!domain && <EmptyForm />}
      {domain && !domain.verified && <PendingState domain={domain} />}
      {domain?.verified && <VerifiedState domain={domain} />}
    </>
  )
}

function EmptyForm() {
  return (
    <section className="flex max-w-[480px] flex-col gap-6 py-6">
      <Form method="post" action="/domain">
        {({ errors, processing }) => (
          <div className="flex flex-col gap-4">
            <Field data-invalid={Boolean(errors.hostname)}>
              <FieldLabel>Domain</FieldLabel>
              <Input
                name="domain[hostname]"
                type="text"
                autoComplete="off"
                placeholder="acme.com"
                className="font-mono"
                autoFocus
                aria-invalid={Boolean(errors.hostname)}
                required
              />
              <FieldError>{errors.hostname?.[0]}</FieldError>
            </Field>

            <div className="flex items-center gap-3">
              <Button type="submit" disabled={processing}>
                {processing ? "Adding..." : "Verify"}
              </Button>
              <p className="text-sm text-muted-foreground">
                We&rsquo;ll show you the DNS records to add next.
              </p>
            </div>
          </div>
        )}
      </Form>
    </section>
  )
}

function PendingState({ domain }: { domain: Domain }) {
  return (
    <section className="flex flex-col gap-8">
      <div className="flex items-baseline justify-between gap-4 border-b border-border pb-4">
        <span className="font-mono text-base text-foreground">{domain.hostname}</span>
        <span className="font-mono text-xs uppercase tracking-wider text-muted-foreground">
          {domain.status}
        </span>
      </div>

      <DnsTable records={domain.dns_records} />

      <div className="flex items-center gap-3">
        <Form method="patch" action="/domain">
          {({ processing }) => (
            <Button type="submit" disabled={processing} variant="outline">
              {processing ? "Re-checking..." : "Re-check"}
            </Button>
          )}
        </Form>
        <Form method="delete" action="/domain">
          {({ processing }) => (
            <button
              type="submit"
              disabled={processing}
              className="text-sm text-muted-foreground underline underline-offset-4 hover:text-foreground"
            >
              Disconnect
            </button>
          )}
        </Form>
      </div>
    </section>
  )
}

function DnsTable({ records }: { records: DnsRecord[] }) {
  return (
    <div className="flex flex-col">
      <div className="grid grid-cols-[0.5fr_1.4fr_2fr_0.6fr] gap-6 border-y border-border py-2 text-[11px] uppercase tracking-wider text-muted-foreground">
        <span>Type</span>
        <span>Name</span>
        <span>Value</span>
        <span className="text-right">Status</span>
      </div>
      <ul className="flex flex-col">
        {records.map((record, idx) => (
          <li
            key={`${record.type}-${record.name}-${idx}`}
            className="grid grid-cols-[0.5fr_1.4fr_2fr_0.6fr] items-start gap-6 border-b border-border py-3 font-mono text-xs"
          >
            <span className="text-foreground">{record.type}</span>
            <span className="break-all text-foreground">{record.name}</span>
            <span className="break-all text-muted-foreground">
              {record.value}
              {record.priority ? ` (priority ${record.priority})` : ""}
            </span>
            <span className="text-right uppercase tracking-wider text-muted-foreground">{record.status}</span>
          </li>
        ))}
      </ul>
    </div>
  )
}

function VerifiedState({ domain }: { domain: Domain }) {
  return (
    <section className="flex flex-col gap-6">
      <dl className="grid grid-cols-[120px_1fr] gap-x-6 gap-y-3 border-b border-border pb-6">
        <dt className="text-sm text-muted-foreground">Hostname</dt>
        <dd className="font-mono text-sm text-foreground">{domain.hostname}</dd>
        <dt className="text-sm text-muted-foreground">Status</dt>
        <dd className="font-mono text-sm text-foreground">verified</dd>
        <dt className="text-sm text-muted-foreground">Verified at</dt>
        <dd className="font-mono text-sm text-foreground">{absoluteTime(domain.verified_at)}</dd>
      </dl>

      <div>
        <Form method="delete" action="/domain">
          {({ processing }) => (
            <button
              type="submit"
              disabled={processing}
              className="text-sm text-muted-foreground underline underline-offset-4 hover:text-foreground"
            >
              Disconnect domain
            </button>
          )}
        </Form>
      </div>
    </section>
  )
}

DomainShow.layout = AppLayout
