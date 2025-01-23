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
    let workout: Workout
    
    init(workout: Workout) {
        self.workout = workout
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(workout.name)
                    .font(.largeTitle)
                    .fontWeight(.medium)
                
                if case .strength(let weight, let repCount, let setCount) = workout.type {
                    WorkoutDataView(label: "Weight", value: "\(weight) lbs")
                    WorkoutDataView(label: "Reps", value: "\(repCount)")
                    WorkoutDataView(label: "Sets", value: "\(setCount)")
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
