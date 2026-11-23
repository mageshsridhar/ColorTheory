//
//  ProgressStore.swift
//  ColorTheory
//

import Foundation

/// Which levels are finished, saved across launches.
final class ProgressStore: ObservableObject {
    @Published private(set) var completed: Set<Level>

    private let defaults: UserDefaults
    private let key = "completedLevels"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        completed = Set((defaults.stringArray(forKey: key) ?? []).compactMap(Level.init(rawValue:)))
    }

    var allCompleted: Bool { completed.isSuperset(of: Level.allCases) }

    func isCompleted(_ level: Level) -> Bool { completed.contains(level) }

    func markCompleted(_ level: Level) {
        guard completed.insert(level).inserted else { return }
        save()
    }

    func reset() {
        completed = []
        save()
    }

    private func save() {
        defaults.set(completed.map(\.rawValue).sorted(), forKey: key)
    }
}
