import Foundation
import SwiftUI

/// A file attachment to include in a mail draft.
public struct MailAttachment: Equatable {
  /// The raw attachment contents.
  public let data: Data

  /// The MIME type of the attachment, such as `text/plain` or `image/png`.
  public let mimeType: String

  /// The filename shown to the recipient.
  public let fileName: String

  /// Creates a mail attachment.
  ///
  /// - Parameters:
  ///   - data: The raw attachment contents.
  ///   - mimeType: The MIME type of the attachment.
  ///   - fileName: The filename shown to the recipient.
  public init(data: Data, mimeType: String, fileName: String) {
    self.data = data
    self.mimeType = mimeType
    self.fileName = fileName
  }
}

/// The message content and recipients used to configure the mail compose sheet.
public struct MailDraft: Identifiable, Equatable {
  /// A stable identifier for SwiftUI sheet presentation.
  public let id: UUID

  /// Primary recipient email addresses.
  public let recipients: [String]

  /// Carbon-copy recipient email addresses.
  public let ccRecipients: [String]

  /// Blind-carbon-copy recipient email addresses.
  public let bccRecipients: [String]

  /// The email subject.
  public let subject: String

  /// The email body.
  public let body: String

  /// A Boolean value that indicates whether ``body`` contains HTML.
  public let isHTML: Bool

  /// Files to attach to the message.
  public let attachments: [MailAttachment]

  /// Creates a mail draft.
  ///
  /// - Parameters:
  ///   - id: A stable identifier for SwiftUI sheet presentation.
  ///   - recipients: Primary recipient email addresses.
  ///   - ccRecipients: Carbon-copy recipient email addresses.
  ///   - bccRecipients: Blind-carbon-copy recipient email addresses.
  ///   - subject: The email subject.
  ///   - body: The email body.
  ///   - isHTML: Whether `body` contains HTML.
  ///   - attachments: Files to attach to the message.
  public init(
    id: UUID = UUID(),
    recipients: [String] = [],
    ccRecipients: [String] = [],
    bccRecipients: [String] = [],
    subject: String = "",
    body: String = "",
    isHTML: Bool = false,
    attachments: [MailAttachment] = []
  ) {
    self.id = id
    self.recipients = recipients
    self.ccRecipients = ccRecipients
    self.bccRecipients = bccRecipients
    self.subject = subject
    self.body = body
    self.isHTML = isHTML
    self.attachments = attachments
  }
}

/// The result returned when the mail compose sheet finishes.
public enum MailComposeResult {
  /// The user cancelled the message.
  case cancelled

  /// The user saved the message as a draft.
  case saved

  /// The message was queued or sent.
  case sent

  /// Mail composition is unavailable on the current device or platform.
  case unavailable

  /// The compose sheet failed, optionally with the underlying error.
  case failed(Error?)
}

#if canImport(MessageUI) && canImport(UIKit)
import MessageUI
import UIKit

/// A SwiftUI wrapper around `MFMailComposeViewController`.
public struct MailComposeView: UIViewControllerRepresentable {
  public typealias UIViewControllerType = UIViewController

  /// The draft used to configure the mail compose sheet.
  public let draft: MailDraft

  /// A closure called after the sheet finishes and dismisses.
  public let onFinish: (MailComposeResult) -> Void

  /// A Boolean value that indicates whether the current device can send mail.
  public static var canSendMail: Bool {
    MFMailComposeViewController.canSendMail()
  }

  /// Creates a mail compose view for a draft.
  ///
  /// - Parameters:
  ///   - draft: The draft used to configure the mail compose sheet.
  ///   - onFinish: A closure called after the sheet finishes and dismisses.
  public init(
    draft: MailDraft,
    onFinish: @escaping (MailComposeResult) -> Void
  ) {
    self.draft = draft
    self.onFinish = onFinish
  }

  /// Creates the underlying UIKit view controller.
  public func makeUIViewController(context: Context) -> UIViewController {
    guard Self.canSendMail else {
      DispatchQueue.main.async {
        context.coordinator.finish(.unavailable)
      }

      return UIViewController()
    }

    let viewController = MFMailComposeViewController()
    viewController.mailComposeDelegate = context.coordinator
    viewController.setToRecipients(draft.recipients)
    viewController.setCcRecipients(draft.ccRecipients)
    viewController.setBccRecipients(draft.bccRecipients)
    viewController.setSubject(draft.subject)
    viewController.setMessageBody(draft.body, isHTML: draft.isHTML)

    for attachment in draft.attachments {
      viewController.addAttachmentData(
        attachment.data,
        mimeType: attachment.mimeType,
        fileName: attachment.fileName
      )
    }

    return viewController
  }

  /// Updates the underlying UIKit view controller.
  public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

  /// Creates the delegate coordinator.
  public func makeCoordinator() -> Coordinator {
    Coordinator(onFinish: onFinish)
  }

  /// The delegate object that bridges UIKit completion callbacks to SwiftUI.
  public final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    private let onFinish: (MailComposeResult) -> Void
    private var didFinish = false

    init(onFinish: @escaping (MailComposeResult) -> Void) {
      self.onFinish = onFinish
    }

    public func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      let composeResult = MailComposeResult(result: result, error: error)
      controller.dismiss(animated: true) {
        self.finish(composeResult)
      }
    }

    func finish(_ result: MailComposeResult) {
      guard !didFinish else {
        return
      }

      didFinish = true
      onFinish(result)
    }
  }
}

private extension MailComposeResult {
  init(result: MFMailComposeResult, error: Error?) {
    switch result {
    case .cancelled:
      self = .cancelled
    case .saved:
      self = .saved
    case .sent:
      self = .sent
    case .failed:
      self = .failed(error)
    @unknown default:
      self = .failed(error)
    }
  }
}
#else
/// A fallback SwiftUI view used when `MessageUI` and `UIKit` are unavailable.
public struct MailComposeView: View {
  /// The draft retained for API consistency on unsupported platforms.
  public let draft: MailDraft

  /// A closure called with `.unavailable` when the fallback view appears.
  public let onFinish: (MailComposeResult) -> Void
  @State private var didFinish = false

  /// A Boolean value that is always `false` on unsupported platforms.
  public static var canSendMail: Bool {
    false
  }

  /// Creates a fallback mail compose view.
  ///
  /// - Parameters:
  ///   - draft: The draft retained for API consistency.
  ///   - onFinish: A closure called with `.unavailable` when the fallback view appears.
  public init(
    draft: MailDraft,
    onFinish: @escaping (MailComposeResult) -> Void
  ) {
    self.draft = draft
    self.onFinish = onFinish
  }

  /// A view that reports mail composition unavailability when it appears.
  public var body: some View {
    EmptyView()
      .onAppear {
        guard !didFinish else {
          return
        }

        didFinish = true
        DispatchQueue.main.async {
          onFinish(.unavailable)
        }
      }
  }
}
#endif
