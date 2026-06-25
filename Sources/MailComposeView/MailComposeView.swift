import Foundation
import SwiftUI

public struct MailAttachment: Equatable {
  public let data: Data
  public let mimeType: String
  public let fileName: String

  public init(data: Data, mimeType: String, fileName: String) {
    self.data = data
    self.mimeType = mimeType
    self.fileName = fileName
  }
}

public struct MailDraft: Identifiable, Equatable {
  public let id: UUID
  public let recipients: [String]
  public let ccRecipients: [String]
  public let bccRecipients: [String]
  public let subject: String
  public let body: String
  public let isHTML: Bool
  public let attachments: [MailAttachment]

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

public enum MailComposeResult {
  case cancelled
  case saved
  case sent
  case failed(Error?)
}

#if canImport(MessageUI) && canImport(UIKit)
import MessageUI
import UIKit

public struct MailComposeView: UIViewControllerRepresentable {
  public typealias UIViewControllerType = MFMailComposeViewController

  public let draft: MailDraft
  public let onFinish: (MailComposeResult) -> Void

  public static var canSendMail: Bool {
    MFMailComposeViewController.canSendMail()
  }

  public init(
    draft: MailDraft,
    onFinish: @escaping (MailComposeResult) -> Void
  ) {
    self.draft = draft
    self.onFinish = onFinish
  }

  public func makeUIViewController(context: Context) -> MFMailComposeViewController {
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

  public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

  public func makeCoordinator() -> Coordinator {
    Coordinator(onFinish: onFinish)
  }

  public final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    private let onFinish: (MailComposeResult) -> Void

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
        self.onFinish(composeResult)
      }
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
public struct MailComposeView: View {
  public let draft: MailDraft
  public let onFinish: (MailComposeResult) -> Void

  public static var canSendMail: Bool {
    false
  }

  public init(
    draft: MailDraft,
    onFinish: @escaping (MailComposeResult) -> Void
  ) {
    self.draft = draft
    self.onFinish = onFinish
  }

  public var body: some View {
    EmptyView()
      .onAppear {
        onFinish(.failed(nil))
      }
  }
}
#endif
