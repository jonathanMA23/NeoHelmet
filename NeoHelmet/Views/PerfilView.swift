import SwiftUI
import FirebaseAuth

struct PerfilView: View {
    // 1. Datos del usuario (Inicialmente vacíos para que el usuario los llene)
    @State private var name: String = ""
    @State private var email: String = "Cargando..." // Se llenará con Firebase
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    
    // 2. Datos de Contactos de Emergencia
    @State private var emergencyPhone1: String = ""
    @State private var emergencyPhone2: String = ""
    
    @State private var isEditing: Bool = false
    @State private var isSendingAlert = false
    @State private var alertPulse = false
    @State private var alertSent = false
    @State private var showLogoutConfirmation = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Encabezado
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Perfil")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Gestiona tu información personal")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // Botón Editar/Guardar
                        Button(action: {
                            withAnimation {
                                isEditing.toggle()
                                if !isEditing {
                                    // Simulación de "Guardado"
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                }
                            }
                        }) {
                            Image(systemName: isEditing ? "checkmark" : "square.and.pencil")
                                .font(.title2)
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.neonGreen)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 20)
                    
                    // 1. Tarjeta de Usuario (Muestra datos reales)
                    UserProfileCard(name: name, email: email)
                    
                    // 2. Información Personal (Editables)
                    PersonalInfoCard(name: $name, weight: $weight, height: $height, age: $age, isEditing: isEditing)
                    
                    // 3. Contactos de Emergencia (Ahora conectados a variables)
                    EmergencyContactsCard(phone1: $emergencyPhone1, phone2: $emergencyPhone2, isEditing: isEditing)
                    
                    // 4. Botón de Alerta
                    Button(action: startEmergencyProtocol) {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text("Enviar Alerta de")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("Emergencia")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.red, Color(red: 0.8, green: 0, blue: 0)]), startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.red.opacity(0.5), radius: 15, x: 0, y: 5)
                    }
                    .opacity(isEditing ? 0.5 : 1.0)
                    .disabled(isEditing)
                    
                    Text("Se notificará a tus contactos de emergencia con tu ubicación actual")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // 5. Estadísticas
                    StatsFooterView()
                    
                    // Botón Cerrar Sesión
                    Button(action: { showLogoutConfirmation = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Cerrar Sesión")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.darkField)
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.top, 10)
                    .confirmationDialog("¿Cerrar sesión?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                        Button("Cerrar Sesión", role: .destructive) {
                            signOut()
                        }
                        Button("Cancelar", role: .cancel) {}
                    }
                    
                    Text("NeoHelmet App v2.4.1")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 20)
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
            }
            .blur(radius: isSendingAlert ? 10 : 0)
            
            // Overlay de Alerta (Igual que antes)
            if isSendingAlert {
                Color.black.opacity(0.9)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if !alertSent { withAnimation { isSendingAlert = false } }
                    }
                
                VStack(spacing: 30) {
                    if alertSent {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle().fill(Color.neonGreen).frame(width: 120, height: 120).shadow(color: .neonGreen.opacity(0.5), radius: 20)
                                Image(systemName: "checkmark").font(.system(size: 60, weight: .bold)).foregroundColor(.black)
                            }
                            .transition(.scale)
                            Text("¡Alerta enviada!").font(.title).fontWeight(.heavy).foregroundColor(.white)
                            Text("Tus contactos han sido notificados").font(.body).foregroundColor(.gray)
                        }
                    } else {
                        VStack(spacing: 30) {
                            ZStack {
                                Circle().fill(Color.red.opacity(0.3)).frame(width: 250, height: 250)
                                    .scaleEffect(alertPulse ? 1.2 : 1.0).opacity(alertPulse ? 0 : 1)
                                    .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: alertPulse)
                                Circle().fill(Color.red).frame(width: 120, height: 120).shadow(color: .red, radius: 20)
                                Image(systemName: "exclamationmark").font(.system(size: 60, weight: .bold)).foregroundColor(.white)
                            }
                            Text("Enviando alerta...").font(.title).fontWeight(.bold).foregroundColor(.white)
                            Button("Cancelar") { withAnimation { isSendingAlert = false } }
                                .foregroundColor(.white).padding().background(Color.white.opacity(0.2)).cornerRadius(20)
                        }
                    }
                }
            }
        }
        // Cargar email al aparecer la vista
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.email = user.email ?? "Sin correo"
            }
        }
    }
    
    // Funciones auxiliares
    func startEmergencyProtocol() {
        withAnimation { isSendingAlert = true; alertPulse = true; alertSent = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring()) { alertSent = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { isSendingAlert = false }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error al salir: \(error.localizedDescription)")
        }
    }
}

// MARK: - Subcomponentes Actualizados

struct UserProfileCard: View {
    let name: String
    let email: String
    
    // Calcular iniciales dinámicamente
    var initials: String {
        let components = name.split(separator: " ")
        if components.count > 0 {
            let first = components[0].prefix(1)
            let second = components.count > 1 ? components[1].prefix(1) : ""
            return "\(first)\(second)".uppercased()
        }
        return "??"
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle().stroke(Color.neonGreen, lineWidth: 2).frame(width: 80, height: 80)
                Circle().fill(Color.darkField).frame(width: 75, height: 75)
                // Mostrar iniciales calculadas
                Text(initials).font(.title).fontWeight(.bold).foregroundColor(.neonGreen)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(name.isEmpty ? "Usuario Nuevo" : name)
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                Text(email)
                    .font(.caption).foregroundColor(.gray)
                
                HStack {
                    Circle().fill(Color.neonGreen).frame(width: 8, height: 8)
                    Text("Usuario Premium").font(.caption2).fontWeight(.bold).foregroundColor(.neonGreen)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.neonGreen.opacity(0.1)).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.neonGreen.opacity(0.3), lineWidth: 1))
            }
            Spacer()
        }
        .padding(20).background(Color.darkField).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct PersonalInfoCard: View {
    @Binding var name: String
    @Binding var weight: String
    @Binding var height: String
    @Binding var age: String
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Información Personal").font(.headline).foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Nombre completo", systemImage: "person").font(.caption).foregroundColor(.gray)
                TextField("Ingresa tu nombre", text: $name)
                    .padding()
                    .background(isEditing ? Color.white.opacity(0.1) : Color.black.opacity(0.3))
                    .cornerRadius(12)
                    .foregroundColor(isEditing ? .neonGreen : .white)
                    .disabled(!isEditing)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(isEditing ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1))
            }
            
            HStack(spacing: 12) {
                InfoBox(icon: "scalemass", title: "Peso (kg)", value: $weight, placeholder: "0", isEditing: isEditing)
                InfoBox(icon: "ruler", title: "Altura (cm)", value: $height, placeholder: "0", isEditing: isEditing)
                InfoBox(icon: "calendar", title: "Edad", value: $age, placeholder: "0", isEditing: isEditing)
            }
        }
        .padding(20).background(Color.darkField).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    @Binding var value: String
    let placeholder: String
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption2).foregroundColor(.gray)
            
            TextField(placeholder, text: $value)
                .font(.title3).fontWeight(.bold)
                .foregroundColor(isEditing ? .neonGreen : .white)
                .multilineTextAlignment(.center).keyboardType(.numberPad)
                .padding(.vertical, 8)
                .background(isEditing ? Color.white.opacity(0.1) : Color.black.opacity(0.3))
                .cornerRadius(10).disabled(!isEditing)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isEditing ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmergencyContactsCard: View {
    @Binding var phone1: String
    @Binding var phone2: String
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "phone.fill").foregroundColor(.neonGreen)
                Text("Contactos de Emergencia").font(.headline).foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                ContactRow(label: "Número de emergencia principal", number: $phone1, placeholder: "Agregar número", isEditing: isEditing)
                Divider().background(Color.gray.opacity(0.3))
                ContactRow(label: "Número de emergencia secundario", number: $phone2, placeholder: "Opcional", isEditing: isEditing)
            }
            .padding().background(Color.black.opacity(0.3)).cornerRadius(15)
        }
        .padding(20).background(Color.darkField).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct ContactRow: View {
    let label: String
    @Binding var number: String
    let placeholder: String
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption).foregroundColor(.gray)
            HStack {
                Image(systemName: "phone.circle.fill").foregroundColor(.neonGreen).font(.title3)
                
                TextField(placeholder, text: $number)
                    .font(.headline)
                    .foregroundColor(isEditing ? .neonGreen : .white)
                    .disabled(!isEditing)
                    .keyboardType(.phonePad)
                
                Spacer()
                if isEditing { Image(systemName: "pencil").foregroundColor(.neonGreen) }
            }
        }
    }
}

struct StatsFooterView: View {
    var body: some View {
        HStack(spacing: 15) {
            FooterStat(value: "0", label: "Viajes")
            FooterStat(value: "0.0k", label: "Km totales")
            FooterStat(value: "2025", label: "Desde")
        }
    }
}

struct FooterStat: View {
    let value: String
    let label: String
    var body: some View {
        VStack {
            Text(value).font(.title3).fontWeight(.bold).foregroundColor(.white)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding().background(Color.darkField).cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
    }
}
