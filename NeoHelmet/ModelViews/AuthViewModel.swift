import SwiftUI
import Combine // Importante para corregir el error de ObservableObject
import FirebaseAuth // Esto solo funcionará si completaste el Paso 2 arriba

// MARK: - Extensiones de Diseño
extension Color {
    // Definimos el "Verde NeoHelmet" exacto de tu diseño
    static let neonGreen = Color(red: 0.6, green: 1.0, blue: 0.0) // Verde lima intenso
    static let darkField = Color(red: 0.1, green: 0.1, blue: 0.1) // Gris muy oscuro para inputs
}

// MARK: - ViewModel de Autenticación
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isAuthenticated = false
    
    func login() {
        validate()
        guard errorMessage.isEmpty else { return }
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isAuthenticated = true
                }
            }
        }
    }
    
    func register() {
        validate()
        guard errorMessage.isEmpty else { return }
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isAuthenticated = true
                }
            }
        }
    }
    
    private func validate() {
        errorMessage = ""
        if email.isEmpty || password.isEmpty {
            errorMessage = "Por favor llena todos los campos"
        } else if password.count < 6 {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
        }
    }
}
