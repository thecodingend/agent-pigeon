import { Form, Head, Link, usePage } from "@inertiajs/react"
import { Mail } from "lucide-react"

import googleSvg from "/assets/google.svg"
import AuthLayout from "./AuthLayout"
import { PasswordInput } from "@/components/password-input"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
  FieldSeparator,
} from "@/components/ui/field"
import { InputGroup, InputGroupAddon, InputGroupInput } from "@/components/ui/input-group"
import type { SharedProps } from "@/types"

export default function SignUp() {
  const { csrf_token } = usePage<SharedProps>().props

  return (
    <Card className="w-full max-w-sm gap-6 shadow-sm">
      <Head title="Create account" />

      <CardHeader>
        <CardTitle className="text-2xl font-semibold tracking-normal">Create account</CardTitle>
        <CardDescription>Start in seconds with Google, or use your email.</CardDescription>
      </CardHeader>

      <CardContent className="flex flex-col gap-6">
        <form action="/users/auth/google_oauth2" method="post">
          <input type="hidden" name="authenticity_token" value={csrf_token} />
          <Button type="submit" variant="outline" className="w-full">
            <img src={googleSvg} alt="" aria-hidden className="size-4" />
            Sign up with Google
          </Button>
        </form>

        <FieldSeparator>or</FieldSeparator>

        <Form method="post" action="/users">
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
                  autoComplete="new-password"
                  invalid={Boolean(errors.password)}
                  required
                />
                <FieldDescription>At least 6 characters.</FieldDescription>
                <FieldError>{errors.password?.[0]}</FieldError>
              </Field>

              <Field data-invalid={Boolean(errors.password_confirmation)}>
                <FieldLabel>Confirm password</FieldLabel>
                <PasswordInput
                  name="user[password_confirmation]"
                  autoComplete="new-password"
                  invalid={Boolean(errors.password_confirmation)}
                  required
                />
                <FieldError>{errors.password_confirmation?.[0]}</FieldError>
              </Field>

              <Button type="submit" disabled={processing} className="w-full">
                {processing ? "Creating..." : "Create account"}
              </Button>
            </FieldGroup>
          )}
        </Form>

        <p className="text-center text-sm text-muted-foreground">
          Already have an account?{" "}
          <Link href="/users/sign_in" className="text-foreground underline underline-offset-4">
            Sign in
          </Link>
        </p>
      </CardContent>
    </Card>
  )
}

SignUp.layout = AuthLayout
