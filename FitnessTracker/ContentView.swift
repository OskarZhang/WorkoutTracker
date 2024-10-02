//
//  ContentView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/1/24.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExercisesListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Exercises")
                }
            TrendsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Trends")
            }
        }
    }
}
