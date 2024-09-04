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
    @State private var zoomScale: CGFloat = 1.0
    @State private var dateRange: ClosedRange<Date>
    
    init(workout: Workout) {
        self.workout = workout
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!
        _dateRange = State(initialValue: startDate...endDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(workout.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if case .strength(let weight, let repCount, let setCount) = workout.type {
                    WorkoutDataView(label: "Weight", value: "\(weight) lbs")
                    WorkoutDataView(label: "Reps", value: "\(repCount)")
                    WorkoutDataView(label: "Sets", value: "\(setCount)")
                }
                
                WorkoutDataView(label: "Date", value: workout.date.formatted(date: .long, time: .omitted))
                
                Text("Progress Chart")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Chart {
                    ForEach(filteredWorkouts, id: \.date) { workout in
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
                .chartXAxis {
                    AxisMarks(preset: .automatic, values: .stride(by: .day, count: strideDayCount)) { value in
                        if let date = value.as(Date.self), shouldShowLabel(for: date) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(formatDate(date))
                        }
                    }
                }
                .chartXScale(domain: dateRange)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let scale = value / zoomScale
                            updateDateRange(scale: scale)
                            zoomScale = value
                        }
                        .onEnded { _ in
                            zoomScale = 1.0
                        }
                )
                .padding()
                
                Text("Pinch to zoom the chart")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    
    var filteredWorkouts: [Workout] {
        workouts
            .filter { $0.name == workout.name && dateRange.contains($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    private func updateDateRange(scale: CGFloat) {
        let currentEndDate = dateRange.upperBound
        let currentStartDate = dateRange.lowerBound
        let currentInterval = currentEndDate.timeIntervalSince(currentStartDate)
        
        let newInterval = currentInterval / scale
        let newStartDate = currentEndDate.addingTimeInterval(-newInterval)
        
        // Ensure we don't zoom out beyond 365 days
        let maxStartDate = Calendar.current.date(byAdding: .day, value: -365, to: currentEndDate)!
        let clampedStartDate = max(newStartDate, maxStartDate)
        
        dateRange = clampedStartDate...currentEndDate
    }
    
    private var strideDayCount: Int {
        let dayCount = Calendar.current.dateComponents([.day], from: dateRange.lowerBound, to: dateRange.upperBound).day ?? 0
        if dayCount <= 7 { return 1 }
        if dayCount <= 30 { return 7 }
        if dayCount <= 90 { return 14 }
        return 30
    }
    
    private func shouldShowLabel(for date: Date) -> Bool {
        let dayCount = Calendar.current.dateComponents([.day], from: dateRange.lowerBound, to: dateRange.upperBound).day ?? 0
        let calendar = Calendar.current
        
        // Only show labels for dates with workouts
        guard filteredWorkouts.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) else {
            return false
        }
        
        if dayCount <= 7 { return true }
        if dayCount <= 30 { return calendar.component(.day, from: date) % 7 == 0 }
        if dayCount <= 90 { return calendar.component(.day, from: date) % 14 == 0 }
        return calendar.component(.day, from: date) == 1 // First day of the month
    }
    
    private func formatDate(_ date: Date) -> String {
        let dayCount = Calendar.current.dateComponents([.day], from: dateRange.lowerBound, to: dateRange.upperBound).day ?? 0
        let formatter = DateFormatter()
        
        if dayCount <= 7 {
            formatter.dateFormat = "MMM d"
        } else if dayCount <= 90 {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM"
        }
        
        return formatter.string(from: date)
    }
}

struct WorkoutDataView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .font(.title3)
        }
    }
}
