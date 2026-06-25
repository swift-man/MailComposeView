# MailComposeView Overview

Present Mail's native compose sheet from SwiftUI.

## Overview

`MailComposeView` wraps `MFMailComposeViewController` with a small SwiftUI API. Apps provide a ``MailDraft`` value, check ``MailComposeView/canSendMail`` before presentation, and handle the resulting ``MailComposeResult`` when the sheet finishes.

```swift
@State private var draft: MailDraft?

Button("Contact support") {
  guard MailComposeView.canSendMail else {
    return
  }

  draft = MailDraft(
    recipients: ["support@example.com"],
    subject: "Support request",
    body: "Please describe the issue."
  )
}
.sheet(item: $draft) { draft in
  MailComposeView(draft: draft) { result in
    self.draft = nil
  }
}
```

Use ``MailAttachment`` to include files in a message.

```swift
let attachment = MailAttachment(
  data: Data("Hello".utf8),
  mimeType: "text/plain",
  fileName: "hello.txt"
)
```

## Topics

### Compose View

- ``MailComposeView``

### Message Data

- ``MailDraft``
- ``MailAttachment``

### Completion

- ``MailComposeResult``
