// swift-tools-version: 6.1
import PackageDescription

let deps: [Package.Dependency] = [
  .github("swiftlang/swift-toolchain-sqlite", exact: "1.0.4"),
  .github("sqlcipher/SQLCipher.swift.git", exact: "4.10.0")
]

let applePlatforms: [PackageDescription.Platform] = [.iOS, .macOS, .watchOS, .tvOS, .visionOS]

let sqlcipherTraitTargetCondition: TargetDependencyCondition? = .when(platforms: applePlatforms, traits: ["SQLCipher"])

let sqlcipherTraitBuildSettingCondition: BuildSettingCondition? = .when(platforms: applePlatforms, traits: ["SQLCipher"])

let targets: [Target] = [
  .target(
    name: "SQLite",
    dependencies: [
      .product(name: "SwiftToolchainCSQLite", package: "swift-toolchain-sqlite", condition: .when(platforms: [.linux, .windows, .android])),
      .product(name: "SQLCipher", package: "SQLCipher.swift", condition: sqlcipherTraitTargetCondition)
    ],
    exclude: [
      "Info.plist"
    ],
    cSettings: [
      .define("SQLITE_HAS_CODEC", to: nil, sqlcipherTraitBuildSettingCondition)
    ],
    swiftSettings: [
      .define("SQLITE_HAS_CODEC", sqlcipherTraitBuildSettingCondition),
      .define("SQLITE_SWIFT_SQLCIPHER", sqlcipherTraitBuildSettingCondition)
    ]
  )
]

let testTargets: [Target] = [
  .testTarget(
    name: "SQLiteTests",
    dependencies: [
      "SQLite"
    ],
    path: "Tests/SQLiteTests",
    exclude: [
      "Info.plist"
    ],
    resources: [
      .copy("Resources")
    ],
    swiftSettings: [
      .define("SQLITE_SWIFT_SQLCIPHER", sqlcipherTraitBuildSettingCondition)
    ]
  )
]

let package = Package(
  name: "SQLite.swift",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_13),
    .watchOS(.v4),
    .tvOS(.v12),
    .visionOS(.v1)
  ],
  products: [
    .library(
      name: "SQLite",
      targets: ["SQLite"]
    )
  ],
  traits: [
    .trait(name: "SQLCipher", description: "Enables SQLCipher encryption when a key is supplied to Connection")
  ],
  dependencies: deps,
  targets: targets + testTargets,
  swiftLanguageModes: [.v5],
)

extension Package.Dependency {
  static func github(_ repo: String, exact ver: Version) -> Package.Dependency {
    .package(url: "https://github.com/\(repo)", exact: ver)
  }
}
