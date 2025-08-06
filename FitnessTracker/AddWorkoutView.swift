//
//  AddWorkoutView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI
import SwiftData
import SwiftUIIntrospect

struct AddWorkoutView: View {

    @State private var viewModel: AddWorkoutViewModel
    @FocusState private var isNameFocused
    @State private var hasSetInitialFocus = false

    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme

    init(isPresented: Binding<Bool>, exerciseService: ExerciseService) {
        self._isPresented = isPresented
        self.viewModel = .init(service: exerciseService)
    }

    var body: some View {
        NavigationView {
            List {

                TextField("Add exercise", text: $viewModel.exerciseName)
                    .autocorrectionDisabled(true)
                    .font(.largeTitle)
                    .focused($isNameFocused)
                    .listRowSeparator(.hidden)
                    .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18), customize: { textField in
                        if !hasSetInitialFocus && isPresented {
                            textField.becomeFirstResponder()
                            hasSetInitialFocus = true
                        }
                    })
                    .onAppear {
                        isNameFocused = true
                    }
                    .onSubmit {
                        if viewModel.isValidInput {
                            saveWorkout()
                        }
                    }

                    .submitLabel(.done)
                    .padding(.top, 16)

                Stepper("Reps \(viewModel.repCount)", value: $viewModel.repCount, in: 1...100)
                    .listRowSeparator(.hidden)
                Stepper("Sets \(viewModel.setCount)", value: $viewModel.setCount, in: 1...10)
                    .listRowSeparator(.hidden)

                DatePicker("Date", selection: $viewModel.exerciseDate, displayedComponents: .date)
                    .listRowSeparator(.hidden)

                Text("Weight")
                SliderView.Representable(value: $viewModel.weight).frame(height: 120)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

            }
            .listStyle(.plain)
            .keyboardToolbar {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom) {
                            ForEach(viewModel.suggestWorkoutNames()) { exercise in
                                Button(exercise.name) {
                                    switch exercise.type {
                                    case .cardio:
                                        break
                                    case .strength:
                                        self.viewModel.weight = Int(exercise.maxWeight)
                                        self.viewModel.repCount = exercise.maxRep
                                        self.viewModel.setCount = exercise.sets?.count ?? 0
                                        self.viewModel.exerciseName = exercise.name
                                    }
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(colorScheme == .dark ? Color.white : Color(UIColor.darkGray))
                                .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            }
                        }
                        .padding(EdgeInsets(top: 0.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
                    }
                    .background(Color(UIColor.systemBackground))
            }
            .tint(colorScheme == .dark ? Color.white : Color(UIColor.black))
        }
    }

    private func saveWorkout() {
        viewModel.save()
        restTimerManager.startTimer(for: viewModel.workoutName)
        isPresented = false
    }

}
