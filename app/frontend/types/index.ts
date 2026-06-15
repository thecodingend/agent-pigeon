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

export type NavContext = {
  email_connection_complete: boolean
  support_address: string | null
} | null

export type SharedProps = {
  auth: {
    user: AuthUser | null
  }
  csrf_token: string
  flash: FlashData
  nav: NavContext
}
