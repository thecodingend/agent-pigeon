import { Form, Head } from "@inertiajs/react"

import { PasswordInput } from "@/components/password-input"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Field, FieldError, FieldGroup, FieldLabel } from "@/components/ui/field"

type Props = {
  reset_password_token: string
}

export default function EditPassword({ reset_password_token }: Props) {
  return (
    <main className="grid min-h-svh place-items-center bg-background p-6">
      <Head title="Choose a new password" />

      <Card className="w-full max-w-sm gap-6 shadow-sm">
        <CardHeader>
          <CardTitle className="text-2xl font-semibold tracking-normal">Choose a new password</CardTitle>
          <CardDescription>Enter the password you want to use from now on.</CardDescription>
        </CardHeader>

        <CardContent>
          <Form method="put" action="/users/password">
            {({ errors, processing }) => (
              <FieldGroup className="gap-4">
                <input type="hidden" name="user[reset_password_token]" value={reset_password_token} />

                <Field data-invalid={Boolean(errors.password)}>
                  <FieldLabel>New password</FieldLabel>
                  <PasswordInput
                    name="user[password]"
                    autoComplete="new-password"
                    autoFocus
                    invalid={Boolean(errors.password)}
                    required
                  />
                  <FieldError>{errors.password?.[0]}</FieldError>
                </Field>

                <Field data-invalid={Boolean(errors.password_confirmation)}>
                  <FieldLabel>Confirm new password</FieldLabel>
                  <PasswordInput
                    name="user[password_confirmation]"
                    autoComplete="new-password"
                    invalid={Boolean(errors.password_confirmation)}
                    required
                  />
                  <FieldError>{errors.password_confirmation?.[0]}</FieldError>
                </Field>

                <Button type="submit" disabled={processing} className="w-full">
                  {processing ? "Saving..." : "Save password"}
                </Button>
              </FieldGroup>
            )}
          </Form>
        </CardContent>
      </Card>
    </main>
  )
}
