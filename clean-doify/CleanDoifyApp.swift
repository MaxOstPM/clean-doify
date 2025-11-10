//
//  CleanDoifyApp.swift
//  clean-doify
//
//  Created by Maksym Ostapchuk on 11/10/25.
//

import SwiftUI
import SwiftData
import os

@main
@MainActor
struct CleanDoifyApp: App {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "clean-doify", category: "SwiftData")
    private static let modelSchema = Schema([Item.self])

    private let modelContainer: ModelContainer

    init() {
        modelContainer = Self.makeModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

private extension CleanDoifyApp {
    static func makeModelContainer() -> ModelContainer {
        do {
            return try persistentModelContainer()
        } catch {
            logger.error("Failed to create persistent ModelContainer: \(error, privacy: .public). Falling back to in-memory storage.")

            do {
                return try inMemoryModelContainer()
            } catch {
                logger.critical("Failed to create in-memory fallback ModelContainer: \(error, privacy: .public)")
                fatalError("Could not create any ModelContainer: \(error)")
            }
        }
    }

    static func persistentModelContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: modelSchema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: modelSchema, configurations: [configuration])
    }

    static func inMemoryModelContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: modelSchema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: modelSchema, configurations: [configuration])
    }
}
