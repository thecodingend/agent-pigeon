export type FlashData = {
  notice?: string
  alert?: string
}

export type UserRole = "regular" | "admin"

export type AuthUser = {
  id: number
  email: string
  role: UserRole
}

export type SharedProps = {
  auth: {
    user: AuthUser | null
  }
  csrf_token: string
  flash: FlashData
}
