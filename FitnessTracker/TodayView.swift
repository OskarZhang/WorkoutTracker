import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var recommendations: [Exercise] = []
    @State private var recommendationService: TodayRecommendationService?
    @State private var selectedExercise: Exercise?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                headerView
                
                if recommendations.isEmpty {
                    emptyStateView
                } else {
                    recommendationsList
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Today")
            .onAppear {
                setupRecommendationService()
                loadRecommendations()
            }
            .sheet(item: $selectedExercise) { exercise in
                NavigationView {
                    SetLoggingView(
                        sets: ExerciseService(modelContext: modelContext).lastExerciseSession(matching: exercise.name)?.sets,
                        isPresented: .constant(true),
                        exerciseName: exercise.name,
                        onSave: { sets in
                            let newExercise = Exercise(
                                name: exercise.name,
                                type: .strength,
                                sets: sets
                            )
                            ExerciseService(modelContext: modelContext).addExercise(newExercise)
                            selectedExercise = nil
                        }
                    )
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggested Workouts")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Based on your workout history and patterns")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No workout suggestions yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start logging workouts to get personalized recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    private var recommendationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(recommendations, id: \.id) { exercise in
                    RecommendationCard(exercise: exercise) {
                        selectedExercise = exercise
                    }
                }
            }
        }
    }
    
    private func setupRecommendationService() {
        let exerciseService = ExerciseService(modelContext: modelContext)
        recommendationService = TodayRecommendationService(
            modelContext: modelContext,
            exerciseService: exerciseService
        )
    }
    
    private func loadRecommendations() {
        guard let service = recommendationService else { return }
        recommendations = service.getTodayRecommendations()
    }
}

struct RecommendationCard: View {
    let exercise: Exercise
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let sets = exercise.sets, !sets.isEmpty {
                        Text("Last: \(lastSetDescription)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(timeSinceLastWorkout)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var lastSetDescription: String {
        guard let sets = exercise.sets,
              let lastSet = sets.max(by: { $0.weightInLbs < $1.weightInLbs }) else {
            return "No previous sets"
        }
        return "\(Int(lastSet.weightInLbs)) lbs × \(lastSet.reps)"
    }
    
    private var timeSinceLastWorkout: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(exercise.date) {
            return "Done today"
        } else if calendar.isDateInYesterday(exercise.date) {
            return "Done yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: exercise.date, to: now).day ?? 0
            return "Done \(days) days ago"
        }
    }
}

#Preview {
    TodayView()
}