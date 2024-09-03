//
//  ContentView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI

enum WorkoutType {
    
    struct DisplayText: Identifiable {
        var id: Int
        var text: String
    }
    
    case strength(weight: Int, repCount: Int, setCount: Int)
    case cardio(durationMinutes: Int)
    
    var displayStrings: [DisplayText] {
        switch self {
        case .strength(let weight, let repCount, let setCount):
            return [DisplayText(id: 0, text: "\(weight) lb(s)"), DisplayText(id: 1, text: "\(repCount) reps"), DisplayText(id: 2, text: "\(setCount) sets")]
        case .cardio(let durationMinutes):
            return [DisplayText(id: 0, text: "\(durationMinutes) minutes")]
        }
    }
}

struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let type: WorkoutType
}

struct ContentView: View {
    @State private var workouts: [Workout] = [
        Workout(name: "Running", type: .cardio(durationMinutes: 10)),
        Workout(name: "Bench Press", type: .strength(weight: 175, repCount: 5, setCount: 5))
    ]
    
    var body: some View {
        ZStack {
            NavigationView {
                List(workouts) { workout in
                    VStack(alignment: .leading) {
                        Text(workout.name)
                            .font(.headline)
                        ForEach(workout.type.displayStrings) {
                            text in
                            Text(text.text).font(.subheadline)
                        }
                    }
                }
                .navigationTitle("Fitness Tracker")
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Add new workout logic here
                        print("Add workout tapped")
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
