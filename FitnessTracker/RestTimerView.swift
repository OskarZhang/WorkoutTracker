//  RestTimerView.swift
//  FitnessTracker
//
//  Created by Jeron on 2025-06-30.
//

import SwiftUI

struct RestTimerView: View {
    @EnvironmentObject var manager: RestTimerManager
    @State private var sliderSeconds: Double = 60
    @State private var isEditingDuration = false

    var body: some View {
        if let exercise = manager.currentExercise {
            content(for: exercise)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding([.horizontal, .bottom])
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: manager.remainingSeconds)
        }
    }

    @ViewBuilder
    private func content(for exercise: String) -> some View {
        VStack(spacing: 12) {
            Text("Rest – \(exercise)")
                .font(.headline)

            Text(timeString)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .minimumScaleFactor(0.5)
                .onTapGesture {
                    withAnimation {
                        isEditingDuration.toggle()
                    }
                }

            if isEditingDuration {
                VStack {
                    Slider(value: $sliderSeconds, in: 15...300, step: 15) {
                        Text("Rest duration")
                    }
                    .onChange(of: sliderSeconds) { newValue in
                        manager.setRestDuration(for: exercise, seconds: Int(newValue))
                    }
                    Text("Tap timer to hide editor")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    sliderSeconds = Double(manager.restDurations[exercise] ?? 60)
                }
            }

            HStack {
                Button(action: manager.cancel) {
                    Label("Cancel", systemImage: "xmark")
                        .labelStyle(.titleAndIcon)
                        .foregroundColor(.red)
                }
                Spacer()
                if manager.remainingSeconds == 0 {
                    Button(action: manager.cancel) { // Dismiss after finished.
                        Label("Done", systemImage: "checkmark")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
    }

    private var timeString: String {
        let minutes = manager.remainingSeconds / 60
        let seconds = manager.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#if DEBUG
struct RestTimerView_Previews: PreviewProvider {
    static var previews: some View {
        RestTimerView()
            .environmentObject(dummyManager)
            .previewLayout(.sizeThatFits)
    }

    static var dummyManager: RestTimerManager {
        let m = RestTimerManager()
        m.startTimer(for: "Bench Press")
        return m
    }
}
#endif 