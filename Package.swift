// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "MailComposeView",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(
      name: "MailComposeView",
      targets: ["MailComposeView"]
    ),
  ],
  targets: [
    .target(
      name: "MailComposeView"
    ),
    .testTarget(
      name: "MailComposeViewTests",
      dependencies: ["MailComposeView"]
    ),
  ]
)
