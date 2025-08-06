//
//  TrendsView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/1/24.
//

import SwiftUI
import SwiftData

struct TrendsView: View {
    @Query var exercises: [Exercise]

    var exerciseNameStats: [(name: String, count: Int, recentDate: Date)] {
        let groupedWorkouts = Dictionary(grouping: exercises, by: { $0.name })
        let stats = groupedWorkouts.map { (name, exercises) -> (name: String, count: Int, recentDate: Date) in
            let count = exercises.count
            let recentDate = exercises.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
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
            List(exerciseNameStats, id: \.name) { item in
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.largeTitle)
                    Text("Last on \(formattedDate(item.recentDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    WorkoutChartView(item.name)
                        .frame(height: 200)
                }
                .padding()
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)

            .navigationTitle("Trends")
        }
    }
}
