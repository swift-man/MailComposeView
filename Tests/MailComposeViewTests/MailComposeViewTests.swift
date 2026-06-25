import XCTest
@testable import MailComposeView

final class MailComposeViewTests: XCTestCase {
  func testMailDraftPreservesCustomIdentifier() {
    let id = UUID()
    let draft = MailDraft(id: id)

    XCTAssertEqual(draft.id, id)
  }

  func testMailDraftStoresPlainTextDefaults() {
    let draft = MailDraft(
      recipients: ["support@example.com"],
      subject: "Hello",
      body: "Plain body"
    )

    XCTAssertEqual(draft.recipients, ["support@example.com"])
    XCTAssertEqual(draft.ccRecipients, [])
    XCTAssertEqual(draft.bccRecipients, [])
    XCTAssertEqual(draft.subject, "Hello")
    XCTAssertEqual(draft.body, "Plain body")
    XCTAssertFalse(draft.isHTML)
    XCTAssertEqual(draft.attachments, [])
  }

  func testMailDraftStoresHTMLAndAttachments() {
    let attachment = MailAttachment(
      data: Data("hello".utf8),
      mimeType: "text/plain",
      fileName: "hello.txt"
    )

    let draft = MailDraft(
      recipients: ["to@example.com"],
      ccRecipients: ["cc@example.com"],
      bccRecipients: ["bcc@example.com"],
      subject: "Report",
      body: "<strong>Hello</strong>",
      isHTML: true,
      attachments: [attachment]
    )

    XCTAssertEqual(draft.ccRecipients, ["cc@example.com"])
    XCTAssertEqual(draft.bccRecipients, ["bcc@example.com"])
    XCTAssertTrue(draft.isHTML)
    XCTAssertEqual(draft.attachments, [attachment])
  }

  func testMailComposeViewReportsUnavailableWhenMessageUIIsUnavailable() {
    #if !(canImport(MessageUI) && canImport(UIKit))
    XCTAssertFalse(MailComposeView.canSendMail)
    #endif
  }

  func testMailComposeViewStoresDraft() {
    let draft = MailDraft(
      id: UUID(),
      recipients: ["support@example.com"],
      subject: "Help",
      body: "Hello"
    )
    let view = MailComposeView(draft: draft) { _ in }

    XCTAssertEqual(view.draft, draft)
  }

  func testMailComposeResultSupportsUnavailableState() {
    let result = MailComposeResult.unavailable

    guard case .unavailable = result else {
      XCTFail("Expected unavailable result")
      return
    }
  }
}
