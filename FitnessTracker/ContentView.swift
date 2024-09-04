import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [Workout]
    @State private var isAddingWorkout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutRow(workout: workout)
                        }                    }
                    .onDelete(perform: deleteWorkouts)
                }
                .navigationTitle("Excercises")
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { isAddingWorkout = true }) {
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
        .sheet(isPresented: $isAddingWorkout) {
            AddWorkoutView(isPresented: $isAddingWorkout, modelContext: modelContext)
                .presentationDetents([.medium,.large])
        }
    }
    
    private func deleteWorkouts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                print("deleting index \(index)")
                modelContext.delete(workouts[index])
            }
        }
    }
}
