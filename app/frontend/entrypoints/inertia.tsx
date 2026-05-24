import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import { createInertiaApp, router } from "@inertiajs/react"
import { toast } from "sonner"

import { Toaster } from "@/components/ui/sonner"
import type { FlashData } from "@/types"

function flashToast(flash: FlashData | null | undefined) {
  if (!flash) return
  if (flash.notice) toast.success(flash.notice)
  if (flash.alert) toast.error(flash.alert)
}

router.on("success", (event) => {
  flashToast(event.detail.page.props.flash)
})

void createInertiaApp({
  pages: "../pages",

  defaults: {
    form: {
      forceIndicesArrayFormatInFormData: false,
      withAllErrors: true,
    },
    visitOptions: () => {
      return { queryStringArrayFormat: "brackets" }
    },
  },

  setup({ el, App, props }) {
    flashToast(props.initialPage.props.flash)

    createRoot(el).render(
      <StrictMode>
        <App {...props} />
        <Toaster />
      </StrictMode>,
    )
  },
}).catch((error) => {
  // This ensures this entrypoint is only loaded on Inertia pages
  // by checking for the presence of the root element (#app by default).
  // Feel free to remove this `catch` if you don't need it.
  if (document.getElementById("app")) {
    throw error
  } else {
    console.error(
      "Missing root element.\n\n" +
      "If you see this error, it probably means you loaded Inertia.js on non-Inertia pages.\n" +
      'Consider moving <%= vite_typescript_tag "inertia.tsx" %> to the Inertia-specific layout instead.',
    )
  }
})
