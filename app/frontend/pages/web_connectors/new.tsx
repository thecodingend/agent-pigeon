import { Form, Head, Link } from "@inertiajs/react"
import { useState } from "react"

import AppLayout from "@/layouts/AppLayout"
import { PageHeader } from "@/components/page-header"
import { Button } from "@/components/ui/button"
import { Field, FieldError, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"

type Props = {
  web_connector: {
    name: string
    description: string
    urls: string[]
    max_depth: number
    max_pages: number
    delay_seconds: number
    concurrency: number
    allow_pdfs: boolean
  }
}

export default function NewWebSource({ web_connector }: Props) {
  const [urls, setUrls] = useState<string[]>(web_connector.urls.length > 0 ? web_connector.urls : [""])

  return (
    <>
      <Head title="New web source · Agent Pigeon" />

      <PageHeader
        title="New web source"
        meta={
          <Link href="/data_sources" className="underline underline-offset-4 hover:text-foreground">
            ← back to library
          </Link>
        }
      />

      <Form method="post" action="/web_connectors">
        {({ errors, processing }) => (
          <div className="flex flex-col gap-10">
            <section className="flex flex-col gap-5">
              <Field data-invalid={Boolean(errors.name)}>
                <FieldLabel>Name</FieldLabel>
                <Input
                  name="web_connector[name]"
                  defaultValue={web_connector.name}
                  placeholder="Help center"
                  autoFocus
                  required
                />
                <FieldError>{errors.name?.[0]}</FieldError>
              </Field>

              <Field data-invalid={Boolean(errors.description)}>
                <FieldLabel>Description</FieldLabel>
                <Textarea
                  name="web_connector[description]"
                  defaultValue={web_connector.description}
                  placeholder="What this collection is about."
                  rows={3}
                />
                <FieldError>{errors.description?.[0]}</FieldError>
              </Field>
            </section>

            <SectionDivider label="URLs" />

            <section className="flex flex-col gap-3">
              <p className="text-xs text-muted-foreground">
                One URL per row. Specific pages only — not domains.
              </p>

              <ul className="flex flex-col gap-2">
                {urls.map((url, idx) => (
                  <li key={idx} className="flex items-center gap-2">
                    <Input
                      name="web_connector[urls][]"
                      type="url"
                      defaultValue={url}
                      placeholder="https://docs.example.com/billing"
                      className="font-mono text-xs"
                    />
                    <button
                      type="button"
                      onClick={() => setUrls((prev) => prev.filter((_, i) => i !== idx))}
                      className="text-xs text-muted-foreground underline underline-offset-4 hover:text-foreground"
                      disabled={urls.length === 1}
                    >
                      Remove
                    </button>
                  </li>
                ))}
              </ul>

              <div>
                <button
                  type="button"
                  onClick={() => setUrls((prev) => [...prev, ""])}
                  className="text-sm text-foreground underline underline-offset-4"
                >
                  + Add URL
                </button>
              </div>

              <FieldError>{errors.urls?.[0]}</FieldError>
            </section>

            <SectionDivider label="Crawl policy" />

            <section className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field data-invalid={Boolean(errors.max_depth)}>
                <FieldLabel>Max depth</FieldLabel>
                <Input
                  name="web_connector[max_depth]"
                  type="number"
                  min={0}
                  max={3}
                  defaultValue={web_connector.max_depth}
                  className="font-mono"
                />
                <FieldError>{errors.max_depth?.[0]}</FieldError>
              </Field>

              <Field data-invalid={Boolean(errors.max_pages)}>
                <FieldLabel>Max pages</FieldLabel>
                <Input
                  name="web_connector[max_pages]"
                  type="number"
                  min={1}
                  max={100}
                  defaultValue={web_connector.max_pages}
                  className="font-mono"
                />
                <FieldError>{errors.max_pages?.[0]}</FieldError>
              </Field>

              <Field data-invalid={Boolean(errors.delay_seconds)}>
                <FieldLabel>Delay seconds</FieldLabel>
                <Input
                  name="web_connector[delay_seconds]"
                  type="number"
                  min={0}
                  max={10}
                  defaultValue={web_connector.delay_seconds}
                  className="font-mono"
                />
                <FieldError>{errors.delay_seconds?.[0]}</FieldError>
              </Field>

              <Field data-invalid={Boolean(errors.concurrency)}>
                <FieldLabel>Concurrency</FieldLabel>
                <Input
                  name="web_connector[concurrency]"
                  type="number"
                  min={1}
                  max={5}
                  defaultValue={web_connector.concurrency}
                  className="font-mono"
                />
                <FieldError>{errors.concurrency?.[0]}</FieldError>
              </Field>

              <label className="flex items-center gap-2 text-sm text-foreground">
                <input type="hidden" name="web_connector[allow_pdfs]" value="0" />
                <input
                  type="checkbox"
                  name="web_connector[allow_pdfs]"
                  value="1"
                  defaultChecked={web_connector.allow_pdfs}
                  className="accent-primary"
                />
                Allow PDFs
              </label>
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

NewWebSource.layout = AppLayout
