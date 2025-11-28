import SwiftUI

struct PerfilView: View {
    // Datos del usuario (Editables)
    @State private var name: String = "Michelle García"
    @State private var email: String = "michelle.garcia@email.com"
    @State private var weight: String = "65"
    @State private var height: String = "165"
    @State private var age: String = "28"
    
    // Estado de Edición
    @State private var isEditing: Bool = false
    
    // Estado para la animación de alerta
    @State private var isSendingAlert = false
    @State private var alertPulse = false
    @State private var alertSent = false // Nuevo estado para el éxito
    
    var body: some View {
        ZStack {
            // Fondo Base
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Encabezado "Perfil"
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
                        
                        // Botón Editar/Guardar (Arriba derecha)
                        Button(action: {
                            withAnimation {
                                isEditing.toggle()
                                // Feedback háptico al guardar
                                if !isEditing {
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
                    
                    // 1. Tarjeta de Usuario Principal
                    UserProfileCard(name: name, email: email)
                    
                    // 2. Información Personal (Peso, Altura, Edad)
                    PersonalInfoCard(name: $name, weight: $weight, height: $height, age: $age, isEditing: isEditing)
                    
                    // 3. Contactos de Emergencia
                    EmergencyContactsCard(isEditing: isEditing)
                    
                    // 4. Botón GRANDE de Alerta
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
                    // Deshabilitar botón mientras se edita para evitar errores
                    .opacity(isEditing ? 0.5 : 1.0)
                    .disabled(isEditing)
                    
                    Text("Se notificará a tus contactos de emergencia con tu ubicación actual")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // 5. Estadísticas Footer
                    StatsFooterView()
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
            }
            .blur(radius: isSendingAlert ? 10 : 0) // Desenfocar fondo al enviar alerta
            
            // OVERLAY: SISTEMA DE ALERTA
            if isSendingAlert {
                Color.black.opacity(0.9)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Solo permite cancelar si no se ha enviado aún
                        if !alertSent {
                            withAnimation { isSendingAlert = false }
                        }
                    }
                
                VStack(spacing: 30) {
                    if alertSent {
                        // VISTA DE ÉXITO (Check Verde)
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.neonGreen)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .neonGreen.opacity(0.5), radius: 20)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .transition(.scale.combined(with: .opacity))
                            
                            VStack(spacing: 10) {
                                Text("¡Alerta enviada!")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                                
                                Text("Tus contactos han sido notificados")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        // VISTA DE ENVIANDO (Pulso Rojo)
                        VStack(spacing: 30) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.3))
                                    .frame(width: 250, height: 250)
                                    .scaleEffect(alertPulse ? 1.2 : 1.0)
                                    .opacity(alertPulse ? 0 : 1)
                                    .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: alertPulse)
                                
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 120, height: 120)
                                    .shadow(color: .red, radius: 20)
                                
                                Image(systemName: "exclamationmark")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 10) {
                                Text("Enviando alerta...")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Contactando números de\nemergencia")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: {
                                withAnimation { isSendingAlert = false }
                            }) {
                                Text("Cancelar")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
        }
    }
    
    func startEmergencyProtocol() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        withAnimation {
            isSendingAlert = true
            alertPulse = true
            alertSent = false // Resetear estado
        }
        
        // Simular proceso de envío (3 segundos)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.spring()) {
                alertSent = true
                generator.notificationOccurred(.success)
            }
            
            // Cerrar automáticamente después de mostrar éxito (2 segundos más)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isSendingAlert = false
                    alertSent = false
                }
            }
        }
    }
}

// MARK: - Subcomponentes Actualizados

struct UserProfileCard: View {
    let name: String
    let email: String
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.neonGreen, lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(Color.darkField)
                    .frame(width: 75, height: 75)
                
                Text(String(name.prefix(2)).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.neonGreen)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(email)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Circle().fill(Color.neonGreen).frame(width: 8, height: 8)
                    Text("Usuario Premium")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.neonGreen)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.neonGreen.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.neonGreen.opacity(0.3), lineWidth: 1))
            }
            Spacer()
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
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
            Text("Información Personal")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Nombre completo", systemImage: "person")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TextField("Nombre", text: $name)
                    .padding()
                    .background(isEditing ? Color.white.opacity(0.1) : Color.black.opacity(0.3))
                    .cornerRadius(12)
                    .foregroundColor(isEditing ? .neonGreen : .white) // Color verde al editar
                    .disabled(!isEditing)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEditing ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            }
            
            HStack(spacing: 12) {
                InfoBox(icon: "scalemass", title: "Peso (kg)", value: $weight, isEditing: isEditing)
                InfoBox(icon: "ruler", title: "Altura (cm)", value: $height, isEditing: isEditing)
                InfoBox(icon: "calendar", title: "Edad", value: $age, isEditing: isEditing)
            }
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    @Binding var value: String
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption2)
            .foregroundColor(.gray)
            
            TextField("0", text: $value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isEditing ? .neonGreen : .white)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .padding(.vertical, 8)
                .background(isEditing ? Color.white.opacity(0.1) : Color.black.opacity(0.3))
                .cornerRadius(10)
                .disabled(!isEditing)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isEditing ? Color.neonGreen.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct EmergencyContactsCard: View {
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.neonGreen)
                Text("Contactos de Emergencia")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                ContactRow(label: "Número de emergencia principal", number: "+52 55 1234 5678", isEditing: isEditing)
                Divider().background(Color.gray.opacity(0.3))
                ContactRow(label: "Número de emergencia secundario", number: "+52 55 8765 4321", isEditing: isEditing)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct ContactRow: View {
    let label: String
    @State var number: String // State local para demo de edición
    var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            HStack {
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(.neonGreen)
                    .font(.title3)
                
                TextField("Número", text: $number)
                    .font(.headline)
                    .foregroundColor(isEditing ? .neonGreen : .white)
                    .disabled(!isEditing)
                
                Spacer()
                
                if isEditing {
                    Image(systemName: "pencil")
                        .foregroundColor(.neonGreen)
                }
            }
        }
    }
}

struct StatsFooterView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                FooterStat(value: "156", label: "Viajes")
                FooterStat(value: "2.4k", label: "Km totales")
                FooterStat(value: "2024", label: "Desde")
            }
            
            Text("NeoHelmet App v2.4.1")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 10)
        }
    }
}

struct FooterStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.darkField)
        .cornerRadius(15)
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
    }
}
