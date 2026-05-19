import { Form, Head, Link } from "@inertiajs/react"
import { Mail } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Field, FieldError, FieldGroup, FieldLabel } from "@/components/ui/field"
import { InputGroup, InputGroupAddon, InputGroupInput } from "@/components/ui/input-group"

export default function NewPassword() {
  return (
    <main className="grid min-h-svh place-items-center bg-background p-6">
      <Head title="Reset password" />

      <Card className="w-full max-w-sm gap-6 shadow-sm">
        <CardHeader>
          <CardTitle className="text-2xl font-semibold tracking-normal">Reset password</CardTitle>
          <CardDescription>We will send reset instructions to your email.</CardDescription>
        </CardHeader>

        <CardContent className="flex flex-col gap-6">
          <Form method="post" action="/users/password">
            {({ errors, processing }) => (
              <FieldGroup className="gap-4">
                <Field data-invalid={Boolean(errors.email)}>
                  <FieldLabel>Email</FieldLabel>
                  <InputGroup>
                    <InputGroupAddon>
                      <Mail />
                    </InputGroupAddon>
                    <InputGroupInput
                      name="user[email]"
                      type="email"
                      autoComplete="email"
                      autoFocus
                      aria-invalid={Boolean(errors.email)}
                      required
                    />
                  </InputGroup>
                  <FieldError>{errors.email?.[0]}</FieldError>
                </Field>

                <Button type="submit" disabled={processing} className="w-full">
                  {processing ? "Sending..." : "Send reset instructions"}
                </Button>
              </FieldGroup>
            )}
          </Form>

          <Link href="/users/sign_in" className="text-center text-sm text-foreground underline underline-offset-4">
            Back to sign in
          </Link>
        </CardContent>
      </Card>
    </main>
  )
}
