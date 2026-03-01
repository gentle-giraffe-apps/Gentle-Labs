import Combine
import SwiftUI

// ─────────────────────────────────────────────────────────────
// Recipe 04: CombineLatest
// ─────────────────────────────────────────────────────────────
// .combineLatest takes the latest value from TWO publishers
// whenever EITHER one emits. The result is a tuple of both
// latest values.
//
// Classic use: form validation — re-evaluate whenever any
// field changes.
// ─────────────────────────────────────────────────────────────

final class FormViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isValid = false
    @Published private(set) var message = "Enter your credentials"

    private var cancellables = Set<AnyCancellable>()

    init() {
        $email.combineLatest($password)
            .map { email, password -> (Bool, String) in
                guard !email.isEmpty && !password.isEmpty else {
                    return (false, "Enter your credentials")
                }
                let emailOK = email.contains("@") && email.contains(".")
                guard emailOK else {
                    return (false, "Enter a valid email")
                }
                guard password.count >= 6 else {
                    return (false, "Password must be 6+ characters")
                }
                return (true, "Ready to submit")
            }
            .sink { [weak self] isValid, message in
                guard let self else { return }
                self.isValid = isValid
                self.message = message
            }
            .store(in: &cancellables)
    }
}

struct Recipe04_CombineLatest: View {
    @StateObject private var vm = FormViewModel()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $vm.email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

            SecureField("Password (6+ chars)", text: $vm.password)
                .textFieldStyle(.roundedBorder)

            Text(vm.message)
                .foregroundStyle(vm.isValid ? .green : .secondary)

            Button("Submit") { }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.isValid)
        }
        .padding(.horizontal)
        .navigationTitle("CombineLatest")
    }
}

#Preview {
    NavigationStack { Recipe04_CombineLatest() }
}
