import { Form, Head, Link, usePage } from "@inertiajs/react"
import { Mail } from "lucide-react"

import googleSvg from "/assets/google.svg"
import AuthLayout from "./AuthLayout"
import { PasswordInput } from "@/components/password-input"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Field, FieldError, FieldGroup, FieldLabel, FieldSeparator } from "@/components/ui/field"
import { InputGroup, InputGroupAddon, InputGroupInput } from "@/components/ui/input-group"
import type { SharedProps } from "@/types"

export default function SignIn() {
  const { csrf_token } = usePage<SharedProps>().props

  return (
    <Card className="w-full max-w-sm gap-6 shadow-sm">
      <Head title="Sign in" />

      <CardHeader>
        <CardTitle className="text-2xl font-semibold tracking-normal">Sign in</CardTitle>
        <CardDescription>Use your email and password, or continue with Google.</CardDescription>
      </CardHeader>

      <CardContent className="flex flex-col gap-6">
        <form action="/users/auth/google_oauth2" method="post">
          <input type="hidden" name="authenticity_token" value={csrf_token} />
          <Button type="submit" variant="outline" className="w-full">
            <img src={googleSvg} alt="" aria-hidden className="size-4" />
            Continue with Google
          </Button>
        </form>

        <FieldSeparator>or</FieldSeparator>

        <Form method="post" action="/users/sign_in">
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

              <Field data-invalid={Boolean(errors.password)}>
                <FieldLabel>Password</FieldLabel>
                <PasswordInput
                  name="user[password]"
                  autoComplete="current-password"
                  invalid={Boolean(errors.password)}
                  required
                />
                <FieldError>{errors.password?.[0]}</FieldError>
              </Field>

              <div className="flex items-center justify-between gap-3 text-sm">
                <FieldLabel>
                  <input name="user[remember_me]" type="checkbox" value="1" className="size-4 rounded border-input" />
                  Remember me
                </FieldLabel>
                <Link href="/users/password/new" className="text-foreground underline underline-offset-4">
                  Forgot password?
                </Link>
              </div>

              <Button type="submit" disabled={processing} className="w-full">
                {processing ? "Signing in..." : "Sign in"}
              </Button>
            </FieldGroup>
          )}
        </Form>

        <div className="flex flex-col gap-2 text-center text-sm text-muted-foreground">
          <p>
            No account?{" "}
            <Link href="/users/sign_up" className="text-foreground underline underline-offset-4">
              Create one
            </Link>
          </p>
          <Link href="/users/confirmation/new" className="text-foreground underline underline-offset-4">
            Resend confirmation email
          </Link>
        </div>
      </CardContent>
    </Card>
  )
}

SignIn.layout = AuthLayout
