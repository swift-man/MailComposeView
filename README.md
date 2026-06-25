# MailComposeView

SwiftUI wrapper for `MFMailComposeViewController`.

`MailComposeView` keeps app-specific copy, recipients, and fallback UI outside the package. The package only provides a small reusable compose surface.

## Requirements

- iOS 13+
- Swift Package Manager

The package can build on macOS for tests, but sending mail is available only when `MessageUI` can present a mail composer.

## Installation

Add the package dependency in Xcode or `Package.swift` using:

```text
https://github.com/swift-man/MailComposeView
```

## Basic Usage

```swift
import MailComposeView
import SwiftUI

struct ContactButton: View {
  @State private var draft: MailDraft?
  @State private var isMailUnavailable = false

  var body: some View {
    Button("Contact") {
      guard MailComposeView.canSendMail else {
        isMailUnavailable = true
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
    .alert("Mail is not available", isPresented: $isMailUnavailable) {
      Button("OK", role: .cancel) {}
    }
  }
}
```

## HTML Body

```swift
let draft = MailDraft(
  recipients: ["support@example.com"],
  subject: "HTML message",
  body: "<h1>Hello</h1><p>This is an HTML email.</p>",
  isHTML: true
)
```

## Attachments

```swift
let attachment = MailAttachment(
  data: Data("Hello".utf8),
  mimeType: "text/plain",
  fileName: "hello.txt"
)

let draft = MailDraft(
  recipients: ["support@example.com"],
  subject: "Attachment",
  body: "See attached file.",
  attachments: [attachment]
)
```

## Unavailable Fallback

`MFMailComposeViewController` requires a configured Mail account. Keep the fallback message in the app so it can be localized for each product.

```swift
guard MailComposeView.canSendMail else {
  isMailUnavailable = true
  return
}
```

If `MailComposeView` is presented on a device or platform where mail composition is unavailable, the completion handler receives `.unavailable`.

## Documentation

Generate the DocC site locally with:

```sh
./GeneratingDocumentationSite
```

The generated static site is written to `docs/`. On `main`, GitHub Actions publishes that output to the `MailComposeView` directory in `swift-man/docs`.

## Public API

- `MailDraft`
- `MailAttachment`
- `MailComposeResult`
- `MailComposeResult.unavailable`
- `MailComposeView`
- `MailComposeView.canSendMail`
