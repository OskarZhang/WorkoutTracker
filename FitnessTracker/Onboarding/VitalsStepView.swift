import SwiftUI

struct VitalsStepView: View {
    @Binding var heightCm: Int
    @Binding var weightKg: Int
    @Binding var age: Int

    // Imperial pickers
    private let feetOptions = Array(4...7)
    private let inchesOptions = Array(0...11)
    private let poundsOptions = Array(80...400)

    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 8
    @State private var selectedPounds: Int = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your vitals").font(.title2).bold()

            HStack(alignment: .center, spacing: 16) {
                VStack {
                    Text("Height")
                    HStack {
                        Picker("Feet", selection: $selectedFeet) {
                            ForEach(feetOptions, id: \.self) { f in
                                Text("\(f) ft").tag(f)
                            }
                        }
                        Picker("Inches", selection: $selectedInches) {
                            ForEach(inchesOptions, id: \.self) { i in
                                Text("\(i) in").tag(i)
                            }
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 150)
                }
                VStack {
                    Text("Weight")
                    Picker("Pounds", selection: $selectedPounds) {
                        ForEach(poundsOptions, id: \.self) { p in
                            Text("\(p) lb").tag(p)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 150)
                }
            }

            // Centered, large age input
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Text("Age")
                    TextField("Age", value: $age, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 36, weight: .bold))
                        .frame(width: 120)
                }
                Spacer()
            }

            Spacer()
        }
        .onAppear(perform: syncImperialFromMetric)
        .onChange(of: selectedFeet) { _ in syncMetricFromImperial() }
        .onChange(of: selectedInches) { _ in syncMetricFromImperial() }
        .onChange(of: selectedPounds) { _ in syncMetricFromImperial() }
        .padding()
    }

    private func syncImperialFromMetric() {
        let totalInches = Int(round(Double(heightCm) / 2.54))
        let feet = max(feetOptions.first!, min(feetOptions.last!, totalInches / 12))
        let inches = max(inchesOptions.first!, min(inchesOptions.last!, totalInches % 12))
        selectedFeet = feet
        selectedInches = inches

        let pounds = Int(round(Double(weightKg) * 2.2046226218))
        selectedPounds = max(poundsOptions.first!, min(poundsOptions.last!, pounds))
    }

    private func syncMetricFromImperial() {
        let totalInches = (selectedFeet * 12) + selectedInches
        heightCm = Int(round(Double(totalInches) * 2.54))
        weightKg = Int(round(Double(selectedPounds) / 2.2046226218))
    }
}


