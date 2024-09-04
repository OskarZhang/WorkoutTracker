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
    @Query private var workouts: [Workout]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(workout.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if case .strength(let weight, let repCount, let setCount) = workout.type {
                    Text("Weight: \(weight) lbs")
                        .font(.title2)
                    Text("Reps: \(repCount)")
                        .font(.title2)
                    Text("Sets: \(setCount)")
                        .font(.title2)
                }
                
                Text("Date: \(workout.date, style: .date)")
                    .font(.title3)
                
                Text("Progress over last 30 days")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Chart {
                    ForEach(last30DaysWorkouts, id: \.date) { workout in
                        if case .strength(let weight, _, _) = workout.type {
                            LineMark(
                                x: .value("Date", workout.date),
                                y: .value("Weight", weight)
                            )
                            PointMark(
                                x: .value("Date", workout.date),
                                y: .value("Weight", weight)
                            )
                        }
                    }
                }
                .frame(height: 300)
                .padding()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var last30DaysWorkouts: [Workout] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return workouts
            .filter { $0.name == workout.name && $0.date >= thirtyDaysAgo }
            .sorted { $0.date < $1.date }
    }
}
