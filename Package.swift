// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TagBasedExpenseTracker",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "TagBasedExpenseTracker",
            targets: ["TagBasedExpenseTracker"]),
        .executable(
            name: "ExpenseTrackerApp",
            targets: ["ExpenseTrackerApp"])
    ],
    dependencies: [
        // SwiftCheck for property-based testing
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "TagBasedExpenseTracker",
            dependencies: [],
            path: "Sources",
            exclude: ["App.swift"]),
        .executableTarget(
            name: "ExpenseTrackerApp",
            dependencies: ["TagBasedExpenseTracker"],
            path: "Sources",
            sources: ["App.swift"]),
        .testTarget(
            name: "TagBasedExpenseTrackerTests",
            dependencies: [
                "TagBasedExpenseTracker",
                "SwiftCheck"
            ],
            path: "Tests"),
    ]
)
