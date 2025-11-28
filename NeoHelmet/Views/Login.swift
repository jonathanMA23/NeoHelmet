//
//  Login.swift
//  NeoHelmet
//
//  Created by Jonathan Mendoza Acevedo on 27/11/25.
//

import SwiftUI
// Descomenta la siguiente línea una vez hayas instalado el SDK de Firebase en tu proyecto
// import FirebaseAuth

// MARK: - ViewModel de Autenticación
// Maneja la lógica de negocio y comunicación con Firebase
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isAuthenticated = false // Úsalo para navegar a la siguiente pantalla
    
    // Función de Login
    func login() {
        validate()
        isLoading = true
        
        // Simulación de retraso de red (Reemplazar con código real de Firebase abajo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            // Si fuera real: Auth.auth().signIn(withEmail: email, password: password) { ... }
            self.isAuthenticated = true // Simulamos éxito
        }
        
        /* CÓDIGO REAL FIREBASE:
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
        */
    }
    
    // Función de Registro
    func register() {
        validate()
        isLoading = true
        
        // Simulación
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.isAuthenticated = true
        }
        
        /* CÓDIGO REAL FIREBASE:
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
        */
    }
    
    private func validate() {
        errorMessage = ""
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor llena todos los campos"
            return
        }
    }
}

// MARK: - Vista de Login
struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLoginMode = true // Alternar entre Login y Registro
    
    var body: some View {
        ZStack {
            // Fondo con degradado animado
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Logo o Título
                VStack {
                    Image(systemName: "swift")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Text(isLoginMode ? "Bienvenido" : "Crear Cuenta")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // Formulario
                VStack(spacing: 15) {
                    TextField("Correo Electrónico", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    SecureField("Contraseña", text: $viewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(5)
                    }
                }
                .padding(.horizontal, 30)
                
                // Botón de Acción
                Button(action: {
                    if isLoginMode {
                        viewModel.login()
                    } else {
                        viewModel.register()
                    }
                }) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        } else {
                            Text(isLoginMode ? "Iniciar Sesión" : "Registrarse")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .disabled(viewModel.isLoading)
                
                // Switcher Login/Registro
                Button(action: {
                    withAnimation {
                        isLoginMode.toggle()
                        viewModel.errorMessage = ""
                    }
                }) {
                    Text(isLoginMode ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia Sesión")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
        // Navegación simulada al éxito
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            // Aquí iría tu ContentView (la vista de tarjetas)
            SuccessPlaceholderView()
        }
    }
}

// MARK: - Placeholder para la navegación
// En la Fase 2, reemplazaremos esto con la integración del ContentView de tarjetas
struct SuccessPlaceholderView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("¡Login Exitoso!")
                .font(.largeTitle)
                .padding()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Button("Cerrar Sesión (Demo)") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
