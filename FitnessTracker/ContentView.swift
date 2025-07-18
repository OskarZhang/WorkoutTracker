//
//  ContentView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/1/24.
//
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            ExercisesListView(workoutService: WorkoutService(modelContext))
                .tabItem {
                    Image(systemName: "dumbbell")
                    Text("Exercises")
                }
            TrendsView()
                .tabItem {
                    Image(systemName: "chart.xyaxis.line")
                    Text("Trends")
            }
        }
        .overlay(alignment: .bottom) {
            RestTimerView()
        }
        .tint(colorScheme == .dark ? Color.white : Color(UIColor.black))
    }
}
