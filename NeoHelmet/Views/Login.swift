//
//  Login.swift
//  NeoHelmet
//
//  Created by Jonathan Mendoza Acevedo on 27/11/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseAnalytics
import Combine
import FirebaseFirestore

// MARK: - Vista de Login Estilo NeoHelmet
struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isLoginMode = true
    
    // Controlamos qué campo está activo para pintar el borde verde
    @FocusState private var focusedField: Field?
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            // 1. Fondo Negro Puro
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // 2. Logo y Título Neon
                VStack(spacing: 15) {
                    ZStack {
                        // Resplandor verde detrás del logo
                        Circle()
                            .fill(Color.neonGreen.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .blur(radius: 20)
                        
                        Image(systemName: "shield") // Icono de escudo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.neonGreen)
                            .font(.system(size: 60, weight: .light))
                            .overlay(
                                // Línea de "escaneo" en el escudo
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.neonGreen)
                                    .offset(y: -5)
                            )
                    }
                    
                    Text("NeoHelmet")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Seguridad vial inteligente")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
                
                // 3. Formulario Oscuro
                VStack(spacing: 25) {
                    // Campo Email
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Correo electrónico")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("tu@email.com", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .email)
                        }
                        .padding()
                        .background(Color.darkField)
                        .cornerRadius(12)
                        // Borde verde neón si está seleccionado
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .email ? Color.neonGreen : Color.clear, lineWidth: 1.5)
                        )
                    }
                    
                    // Campo Contraseña
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Contraseña")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            SecureField("••••••••", text: $viewModel.password)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .password)
                            
                            // Botón "ojo" decorativo
                            Image(systemName: "eye")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.darkField)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .password ? Color.neonGreen : Color.clear, lineWidth: 1.5)
                        )
                    }
                    
                    // Olvidaste contraseña
                    HStack {
                        Spacer()
                        Button("¿Olvidaste tu contraseña?") {
                            // Acción pendiente
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    
                    // Mensaje de Error
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // 4. Botón de Acción Neon
                VStack(spacing: 20) {
                    Button(action: {
                        if isLoginMode {
                            viewModel.login()
                        } else {
                            viewModel.register()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text(isLoginMode ? "Iniciar sesión" : "Registrarse")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black) // Texto negro sobre verde para contraste
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.neonGreen)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    // Switcher Registro/Login
                    HStack {
                        Text(isLoginMode ? "¿No tienes cuenta?" : "¿Ya tienes cuenta?")
                            .foregroundColor(.gray)
                        Button(action: {
                            withAnimation {
                                isLoginMode.toggle()
                                viewModel.errorMessage = ""
                            }
                        }) {
                            Text(isLoginMode ? "Regístrate" : "Inicia sesión")
                                .fontWeight(.bold)
                                .foregroundColor(.neonGreen)
                        }
                    }
                    .font(.subheadline)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        // Navegación principal a la App
        .fullScreenCover(isPresented: $viewModel.isAuthenticated) {
            ContentView() // <--- CAMBIO AQUÍ: Ahora vamos a la app real
        }
        // Verificar si el usuario ya tiene sesión iniciada al abrir la app
        .onAppear {
            if Auth.auth().currentUser != nil {
                viewModel.isAuthenticated = true
            }
        }
    }
}

// Vista temporal de éxito (YA NO SE USA, pero la dejo por si acaso)
struct SuccessPlaceholderView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color.neonGreen)
                Text("¡Acceso Concedido!")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                
                Button("Cerrar Sesión") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .foregroundColor(.gray)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
    }
}
