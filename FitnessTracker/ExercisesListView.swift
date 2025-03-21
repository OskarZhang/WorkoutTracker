import SwiftUI
import SwiftData

struct ExercisesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    
    let workoutService: WorkoutService
    
    init(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }
    
    var groupedWorkouts: [(date: Date, workouts: [Workout])] {
        let startTime = Date().timeIntervalSince1970
        let groupedDict = Dictionary(grouping: workouts) { workout in
            // Normalize the date to remove time components
            Calendar.current.startOfDay(for: workout.date)
        }
        // Sort the dates in descending order
        let sortedDates = groupedDict.keys.sorted(by: >)
        // Map the sorted dates to an array of tuples
        let res = sortedDates.map { date in
            (date: date, workouts: groupedDict[date]!)
        }
        let endTime = Date().timeIntervalSince1970
        debugPrint("grouping perf \(endTime - startTime)s")
        return res
    }
    @Environment(\.colorScheme) var colorScheme

    @State private var isAddingWorkout = false
    @State private var isPresentingExperimentalAdd = false
    @State private var showingSettings = false
    @State private var showingImportFileSelector = false

    @State private var isShareSheetPresented: Bool = false
    @State private var exportedCSVFileURL: URL?
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if workouts.isEmpty {
                        Text("No workouts found in the last 7 days")
                    } else {
                        List {
                            ForEach(groupedWorkouts, id: \.date) { group in
                                Section(header: Text(ExercisesListView.formattedDate(group.date))) {
                                    ForEach(group.workouts) { workout in
                                        WorkoutRow(workout: workout).background(NavigationLink("", destination: WorkoutDetailView(workout: workout))
                                            .opacity(0)
                                        )
                                        .listRowSeparator(.hidden)
                                    }
                                    .onDelete(perform: deleteWorkouts)
                                }
                                
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Exercises")
                .toolbar {
                    Button("", systemImage: "gear") {
                        showingSettings = true
                        exportAndPrepareShare()
                    }
                    
                }
                .confirmationDialog("", isPresented: $showingSettings) {
                    Button("Import") {
                        showingImportFileSelector.toggle()
                        print("tapped")
                    }
                    
                    if let csvURL = exportedCSVFileURL {
                        ShareLink(item: csvURL) {
                            Label("Export", systemImage: "square.and.arrow.up")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    } else {
                        EmptyView()
                    }
                }
                .fileImporter(isPresented: $showingImportFileSelector, allowedContentTypes: [.item], allowsMultipleSelection: false) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            importFrom(fileURL: url)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { isAddingWorkout = true }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(colorScheme == .dark ? Color.white : Color.black)
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingWorkout) {
            AddWorkoutView(isPresented: $isAddingWorkout, workoutService: workoutService)
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
    
    private func importFrom(fileURL: URL) {
        let importer = CSVImporter()
        _ = fileURL.startAccessingSecurityScopedResource()

        do {
            let csvInput = try String(contentsOf: fileURL)

            // Parse the CSV
            let workouts = try importer.importCSV(csvString: csvInput)
            
            // Use the parsed workouts
            for workout in workouts {
                print("Workout ID: \(workout.id)")
                print("Name: \(workout.name)")
                switch workout.type {
                case .strength(let weight, let reps, let sets):
                    print("Type: Strength")
                    print("Weight: \(weight) lbs")
                    print("Reps: \(reps)")
                    print("Sets: \(sets)")
                case .cardio(let duration):
                    print("Type: Cardio")
                    print("Duration: \(duration) minutes")
                }
                modelContext.insert(workout)
            }
        } catch {
            print("Failed to import CSV: \(error.localizedDescription)")
        }
    }
    
    /// Function to export workouts to CSV and prepare the shareable file
    private func exportAndPrepareShare() {
        let exporter = CSVExporter()
        let csvString = exporter.export(workouts: workouts)
        
        // Define the temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "workouts_\(Date().timeIntervalSince1970).csv"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            // Write the CSV string to the temporary file
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            // Update the state to trigger ShareSheet
            exportedCSVFileURL = fileURL
            
        } catch {
            print("Failed to write CSV file: \(error.localizedDescription)")
            errorMessage = "Failed to export workouts. Please try again."
            showErrorAlert = true
        }
    }
    
    private static func recentFilter() -> Predicate<Workout> {
        let recentCutOffDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return #Predicate<Workout> { $0.date >= recentCutOffDate}
    }
    
    private static func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium // You can choose .short, .medium, .long, or .full
            return formatter.string(from: date)
        }
    }
}



struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
                
            Text(workout.name)
                .font(.system(size: 20, weight: .medium))
            
            switch workout.type {
            case .strength(let weight, let repCount, let setCount):
                Text("\(weight) lbs, \(repCount) reps, \(setCount) sets")
                    .font(.callout)
            case .cardio(let durationMinutes):
                Text("Cardio: \(durationMinutes) minutes")
                    .font(.callout)
            }
        }

    }
}
