//  RestTimerManager.swift
//  FitnessTracker
//
//  Created by Jeron on 2025-06-30.
//

import Foundation
import Combine
import SwiftUI

/// Manages per-exercise rest durations and an active countdown timer.
/// The chosen duration for every exercise is persisted via `UserDefaults` so it is remembered between app launches.
final class RestTimerManager: ObservableObject {
    /// The exercise that is currently resting, `nil` when no active timer.
    @Published private(set) var currentExercise: String? = nil
    /// Seconds remaining in the active countdown. When this reaches **0** the timer stops automatically.
    @Published private(set) var remainingSeconds: Int = 0
    /// A map from *exercise name* to its preferred rest duration, measured in **seconds**.
    /// If an exercise is not found in this dictionary we fall back to `defaultRestSeconds`.
    @Published private(set) var restDurations: [String: Int]

    /// The default rest duration (1 minute).
    private let defaultRestSeconds: Int = 60
    private var timer: Timer?

    // MARK: - Persistence

    private static let storageKey = "restDurations"

    init() {
        // Load persisted durations if available.
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            restDurations = decoded
        } else {
            restDurations = [:]
        }
    }

    /// Starts a countdown for the supplied exercise.
    /// - Parameter exercise: The exercise name.
    func startTimer(for exercise: String) {
        // Cancel any existing timer.
        timer?.invalidate()

        currentExercise = exercise
        remainingSeconds = restDurations[exercise] ?? defaultRestSeconds

        guard remainingSeconds > 0 else {
            // Nothing to count down – treat as finished.
            finish()
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// Cancels the currently-running timer (if any).
    func cancel() {
        timer?.invalidate()
        timer = nil
        currentExercise = nil
        remainingSeconds = 0
    }

    /// Sets a new preferred rest duration for the given exercise.
    /// - Parameters:
    ///   - exercise: The exercise name.
    ///   - seconds: Desired duration in seconds.
    func setRestDuration(for exercise: String, seconds: Int) {
        restDurations[exercise] = seconds
        persistRestDurations()

        // If we are actively timing *this* exercise update the countdown to reflect the new duration.
        if exercise == currentExercise {
            remainingSeconds = seconds
        }
    }

    // MARK: - Internals

    private func tick() {
        guard remainingSeconds > 0 else {
            finish()
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            finish()
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
    }

    private func persistRestDurations() {
        if let data = try? JSONEncoder().encode(restDurations) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
} 