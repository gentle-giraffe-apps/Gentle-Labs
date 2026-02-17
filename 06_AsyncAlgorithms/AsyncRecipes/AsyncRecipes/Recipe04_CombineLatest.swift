import AsyncAlgorithms
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 04: CombineLatest
// ─────────────────────────────────────────────────────────────
// Combine equivalent: $email.combineLatest($password).sink
//
// For simple form validation, @Observable computed properties
// are the idiomatic replacement — no streams needed at all.
// (See isValid and message below.)
//
// AsyncAlgorithms' combineLatest is for when you have two
// INDEPENDENT async data sources emitting at different rates.
// This recipe shows both approaches.
// ─────────────────────────────────────────────────────────────

// MARK: - Form validation (computed properties — the easy way)

@Observable
class FormViewModel {
    var email = ""
    var password = ""

    var isValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    var message: String {
        guard !email.isEmpty || !password.isEmpty else {
            return "Enter your credentials"
        }
        guard email.contains("@") && email.contains(".") else {
            return "Enter a valid email"
        }
        guard password.count >= 6 else {
            return "Password must be 6+ characters"
        }
        return "Ready to submit"
    }
}

// MARK: - Sensor dashboard (streams — when you actually need combineLatest)

@Observable
class SensorViewModel {
    private(set) var temperature = "--"
    private(set) var humidity = "--"
    private(set) var comfort = "Waiting for sensors..."

    func startMonitoring() async {
        let temps = AsyncStream<Int> { continuation in
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(Double.random(in: 1...2)))
                    continuation.yield(Int.random(in: 68...82))
                }
            }
        }

        let humids = AsyncStream<Int> { continuation in
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(Double.random(in: 1.5...3)))
                    continuation.yield(Int.random(in: 35...65))
                }
            }
        }

        for await (temp, humid) in combineLatest(temps, humids) {
            temperature = "\(temp)°F"
            humidity = "\(humid)%"
            comfort = temp > 76 && humid > 55 ? "Warm & humid" : "Comfortable"
        }
    }
}

// MARK: - View (shows both approaches)

struct Recipe04_CombineLatest: View {
    @State private var form = FormViewModel()
    @State private var sensors = SensorViewModel()

    var body: some View {
        List {
            Section("Computed Properties (simple validation)") {
                TextField("Email", text: $form.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password (6+ chars)", text: $form.password)
                Text(form.message)
                    .foregroundStyle(form.isValid ? .green : .secondary)
                Button("Submit") { }
                    .disabled(!form.isValid)
            }

            Section("combineLatest (independent streams)") {
                LabeledContent("Temperature", value: sensors.temperature)
                LabeledContent("Humidity", value: sensors.humidity)
                LabeledContent("Comfort", value: sensors.comfort)
            }
        }
        .navigationTitle("CombineLatest")
        .task { await sensors.startMonitoring() }
    }
}

#Preview {
    NavigationStack { Recipe04_CombineLatest() }
}
