//
//  TrendsView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/1/24.
//

import SwiftUI
import SwiftData

struct TrendsView: View {
    @Query var workouts: [Workout]
    
    var workoutNameStats: [(name: String, count: Int, recentDate: Date)] {
        let groupedWorkouts = Dictionary(grouping: workouts, by: { $0.name })
        let stats = groupedWorkouts.map { (name, workouts) -> (name: String, count: Int, recentDate: Date) in
            let count = workouts.count
            let recentDate = workouts.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
            return (name: name, count: count, recentDate: recentDate)
        }
        return stats.sorted(by: { $0.recentDate > $1.recentDate })
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            List(workoutNameStats, id: \.name) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text("Last performed on \(formattedDate(item.recentDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        WorkoutChartView(item.name)
                            .frame(height: 300)
                    }
                    Spacer()
                    Text("\(item.count)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Trends")
        }
    }
}
