import { useState } from "react"
import { Eye, EyeOff, LockKeyhole } from "lucide-react"

import {
  InputGroup,
  InputGroupAddon,
  InputGroupButton,
  InputGroupInput,
} from "@/components/ui/input-group"

type Props = Omit<React.ComponentProps<typeof InputGroupInput>, "type"> & {
  invalid?: boolean
}

export function PasswordInput({ invalid, ...props }: Props) {
  const [show, setShow] = useState(false)

  return (
    <InputGroup>
      <InputGroupAddon>
        <LockKeyhole />
      </InputGroupAddon>
      <InputGroupInput
        type={show ? "text" : "password"}
        aria-invalid={invalid}
        {...props}
      />
      <InputGroupAddon align="inline-end">
        <InputGroupButton
          type="button"
          size="icon-xs"
          aria-label={show ? "Hide password" : "Show password"}
          aria-pressed={show}
          onClick={() => setShow((value) => !value)}
        >
          {show ? <EyeOff /> : <Eye />}
        </InputGroupButton>
      </InputGroupAddon>
    </InputGroup>
  )
}
