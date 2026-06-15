import { Form, Head } from "@inertiajs/react";
import { AlertCircle, CheckCircle2, Clock3, RefreshCw } from "lucide-react";

import AppLayout from "@/layouts/AppLayout";
import { PageHeader } from "@/components/page-header";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import { absoluteTime } from "@/lib/time";

type DnsRecord = {
  record?: string;
  type: string;
  name: string;
  value: string;
  priority?: number;
  status?: string;
};

type SendingDomain = {
  hostname: string;
  status: "pending" | "checking" | "verified" | "failed";
  verified: boolean;
  verified_at: string | null;
  dns_records: DnsRecord[];
  return_path_label: string;
};

type EmailConnection = {
  support_address: string;
  forwarding_address: string;
  forwarding_status: "needs_forwarding" | "ready";
  forwarding_ready: boolean;
  forwarding_verified_at: string | null;
  complete: boolean;
  sending_domain: SendingDomain;
};

type Props = { email_connection: EmailConnection | null };

export default function EmailConnectionShow({ email_connection }: Props) {
  return (
    <>
      <Head title="Email Connection · Agent Pigeon" />

      <PageHeader
        title="Email Connection"
        meta={
          email_connection
            ? email_connection.complete
              ? "Ready to receive support email."
              : "Finish sending verification and forwarding."
            : "Connect a support address on a domain you control."
        }
      />

      {!email_connection ? (
        <SupportAddressForm />
      ) : (
        <ConnectionSetup connection={email_connection} />
      )}
    </>
  );
}

function SupportAddressForm() {
  return (
    <section className="flex max-w-130 flex-col gap-6 py-6">
      <Form method="post" action="/email_connection">
        {({ errors, processing }) => (
          <div className="flex flex-col gap-4">
            <Field data-invalid={Boolean(errors.support_address)}>
              <FieldLabel>Support address</FieldLabel>
              <Input
                name="email_connection[support_address]"
                type="email"
                autoComplete="email"
                placeholder="support@yourcompany.com"
                className="font-mono"
                autoFocus
                required
                aria-invalid={Boolean(errors.support_address)}
              />
              <FieldError>{errors.support_address?.[0]}</FieldError>
            </Field>

            <div className="flex items-center gap-3">
              <Button type="submit" disabled={processing}>
                {processing ? "Starting..." : "Start connection"}
              </Button>
              <p className="text-sm text-muted-foreground">
                We&rsquo;ll show DNS records and forwarding instructions next.
              </p>
            </div>
          </div>
        )}
      </Form>
    </section>
  );
}

function ConnectionSetup({ connection }: { connection: EmailConnection }) {
  return (
    <section className="flex flex-col gap-10">
      <header className="grid grid-cols-[150px_1fr] gap-x-6 gap-y-2 border-b border-border pb-5">
        <span className="text-sm text-muted-foreground">Support address</span>
        <span className="font-mono text-sm text-foreground">
          {connection.support_address}
        </span>
        <span className="text-sm text-muted-foreground">Overall</span>
        <span>
          <StatusBadge
            status={connection.complete ? "complete" : "incomplete"}
          />
        </span>
      </header>

      <SendingSetup connection={connection} />
      <ForwardingSetup connection={connection} />
    </section>
  );
}

function SendingSetup({ connection }: { connection: EmailConnection }) {
  const domain = connection.sending_domain;

  return (
    <SetupSection
      label="Sending setup"
      status={domain.status}
      meta={
        domain.verified
          ? `Verified ${absoluteTime(domain.verified_at)}`
          : `Add these records for ${domain.hostname}, then check DNS.`
      }
    >
      <DnsTable
        records={domain.dns_records}
        returnPathLabel={domain.return_path_label}
      />

      <div className="flex items-center gap-3">
        <Form method="post" action="/email_connection/check_dns">
          {({ processing }) => (
            <Button
              type="submit"
              disabled={processing || domain.verified}
              variant="outline"
            >
              <RefreshCw className="size-4" />
              {processing ? "Checking..." : "Check DNS records"}
            </Button>
          )}
        </Form>
        <p className="text-sm text-muted-foreground">
          Refresh this page after Resend finishes checking.
        </p>
      </div>
    </SetupSection>
  );
}

function ForwardingSetup({ connection }: { connection: EmailConnection }) {
  return (
    <SetupSection
      label="Forwarding setup"
      status={connection.forwarding_status}
      meta={
        connection.forwarding_ready
          ? `Ready ${absoluteTime(connection.forwarding_verified_at)}`
          : "Forward support email to this address, then send a test email."
      }
    >
      <div className="grid grid-cols-[150px_1fr] gap-x-6 gap-y-3 border-y border-border py-4">
        <span className="text-sm text-muted-foreground">Forward to</span>
        <span className="break-all font-mono text-sm text-foreground select-all">
          {connection.forwarding_address}
        </span>
        <span className="text-sm text-muted-foreground">Test by emailing</span>
        <span className="break-all font-mono text-sm text-foreground">
          {connection.support_address}
        </span>
      </div>
    </SetupSection>
  );
}

function SetupSection({
  label,
  status,
  meta,
  children,
}: {
  label: string;
  status: string;
  meta: string;
  children: React.ReactNode;
}) {
  return (
    <section className="flex flex-col gap-5">
      <header className="flex items-start justify-between gap-6 pb-2">
        <div className="flex flex-col gap-1">
          <h2 className="text-sm font-semibold tracking-tight text-foreground">
            {label}
          </h2>
          <span className="text-sm text-muted-foreground">{meta}</span>
        </div>
        <StatusBadge status={status} />
      </header>
      {children}
    </section>
  );
}

function DnsTable({
  records,
  returnPathLabel,
}: {
  records: DnsRecord[];
  returnPathLabel: string;
}) {
  const bounceRecords = records.filter(
    (record) => record.name === returnPathLabel,
  );
  const sendingRecords = records.filter(
    (record) => record.name !== returnPathLabel,
  );

  return (
    <div className="flex flex-col gap-6">
      <DnsGroup label="Sending verification" records={sendingRecords} />
      {bounceRecords.length > 0 ? (
        <DnsGroup label="Bounce handling" records={bounceRecords} />
      ) : null}
    </div>
  );
}

function DnsGroup({ label, records }: { label: string; records: DnsRecord[] }) {
  if (records.length === 0) return null;

  return (
    <div className="flex flex-col gap-2">
      <h3 className="text-xs font-semibold tracking-tight text-foreground">
        {label}
      </h3>
      <div className="grid grid-cols-[0.5fr_1.2fr_2fr_0.7fr] gap-6 border-y border-border py-2 text-[11px] uppercase tracking-wider text-muted-foreground">
        <span>Type</span>
        <span>Name</span>
        <span>Value</span>
        <span className="text-right">Status</span>
      </div>
      <ul className="flex flex-col">
        {records.map((record, idx) => (
          <li
            key={`${record.type}-${record.name}-${idx}`}
            className="grid grid-cols-[0.5fr_1.2fr_2fr_0.7fr] items-start gap-6 border-b border-border py-3 font-mono text-xs"
          >
            <span className="text-foreground">{record.type}</span>
            <span className="break-all text-foreground">{record.name}</span>
            <span className="break-all text-muted-foreground">
              {record.value}
              {record.priority ? ` (priority ${record.priority})` : ""}
            </span>
            <span className="flex justify-end">
              <StatusBadge status={record.status ?? "pending"} size="sm" />
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

function StatusBadge({
  status,
  size = "default",
}: {
  status: string;
  size?: "default" | "sm";
}) {
  const spec = statusSpec(status);
  const Icon = spec.icon;

  return (
    <span
      className={cn(
        "inline-flex w-fit items-center rounded-full border font-mono font-medium uppercase tracking-wider",
        spec.className,
        size === "sm"
          ? "gap-1 px-1.5 py-0.5 text-[10px]"
          : "gap-1.5 px-2 py-1 text-[11px]",
      )}
    >
      <Icon
        className={size === "sm" ? "size-3" : "size-3.5"}
        aria-hidden="true"
      />
      {spec.label}
    </span>
  );
}

function statusSpec(status: string) {
  switch (status) {
    case "complete":
      return {
        label: "Complete",
        icon: CheckCircle2,
        className:
          "border-[oklch(0.76_0.09_148_/_0.45)] bg-[oklch(0.97_0.025_148)] text-[oklch(0.34_0.10_148)]",
      };
    case "verified":
      return {
        label: "Verified",
        icon: CheckCircle2,
        className:
          "border-[oklch(0.76_0.09_148_/_0.45)] bg-[oklch(0.97_0.025_148)] text-[oklch(0.34_0.10_148)]",
      };
    case "ready":
      return {
        label: "Ready",
        icon: CheckCircle2,
        className:
          "border-[oklch(0.76_0.09_148_/_0.45)] bg-[oklch(0.97_0.025_148)] text-[oklch(0.34_0.10_148)]",
      };
    case "checking":
      return {
        label: "Checking",
        icon: Clock3,
        className:
          "border-[oklch(0.72_0.08_235_/_0.45)] bg-[oklch(0.97_0.02_235)] text-[oklch(0.36_0.09_235)]",
      };
    case "failed":
      return {
        label: "Failed",
        icon: AlertCircle,
        className:
          "border-[oklch(0.76_0.12_24_/_0.45)] bg-[oklch(0.97_0.025_24)] text-[oklch(0.43_0.14_24)]",
      };
    case "pending":
      return {
        label: "Pending",
        icon: Clock3,
        className:
          "border-[oklch(0.78_0.10_72_/_0.5)] bg-[oklch(0.97_0.035_72)] text-[oklch(0.40_0.10_72)]",
      };
    case "needs_forwarding":
      return {
        label: "Forwarding needed",
        icon: AlertCircle,
        className:
          "border-[oklch(0.78_0.10_72_/_0.5)] bg-[oklch(0.97_0.035_72)] text-[oklch(0.40_0.10_72)]",
      };
    case "incomplete":
      return {
        label: "Action needed",
        icon: AlertCircle,
        className:
          "border-[oklch(0.78_0.10_72_/_0.5)] bg-[oklch(0.97_0.035_72)] text-[oklch(0.40_0.10_72)]",
      };
    default:
      return {
        label: status.split("_").join(" "),
        icon: Clock3,
        className: "border-border bg-secondary text-muted-foreground",
      };
  }
}

EmailConnectionShow.layout = AppLayout;
