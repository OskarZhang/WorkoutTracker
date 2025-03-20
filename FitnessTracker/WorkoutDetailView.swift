//
//  WorkoutDetailView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/3/24.
//

import SwiftUI
import SwiftData
import Charts

struct WorkoutDetailView: View {
    let workout: ExcerciseDataType

    init(workout: ExcerciseDataType) {
        self.workout = workout
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(workout.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)

                if case .strength = workout.type,
                   let sets = workout.sets {
                    ForEach(sets.indices, id: \.self) { setIndex in
                        WorkoutDataView(label: "Weight", value: "\(sets[setIndex].weightInLbs) lbs")
                        WorkoutDataView(label: "Reps", value: "\(sets[setIndex].reps)")
                    }
                }

                WorkoutDataView(label: "Date", value: workout.date.formatted(date: .long, time: .omitted))

                Text("Progress Chart")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.top)

                WorkoutChartView(workout.name)
                    .frame(height: 300)
                .padding()

                Text("Pinch to zoom on the chart")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkoutDataView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
