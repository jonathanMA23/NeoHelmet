import SwiftUI

// MARK: - Modelos de Datos
struct LedColor: Identifiable {
    let id = UUID()
    let color: Color
    let name: String
}

struct LedPattern: Identifiable {
    let id: String // El nombre es el ID
    let icon: String
    let desc: String
}

// MARK: - Vista Principal de LED
struct LedView: View {
    // Estado de la UI
    @State private var isLedOn = true
    @State private var brightness: Double = 75
    @State private var selectedColor: Color = .neonGreen
    @State private var selectedPattern: String = "Sólido"
    
    // Datos de Colores (Basado en tus imágenes)
    let ledColors: [LedColor] = [
        LedColor(color: .neonGreen, name: "Verde Neón"),
        LedColor(color: .blue, name: "Azul"),
        LedColor(color: .pink, name: "Rojo"), // Usamos pink/red para ese tono neón rojizo
        LedColor(color: .yellow, name: "Amarillo"),
        LedColor(color: .purple, name: "Púrpura"),
        LedColor(color: .white, name: "Blanco")
    ]
    
    // Datos de Patrones
    let patterns: [LedPattern] = [
        LedPattern(id: "Sólido", icon: "sun.max.fill", desc: "Luz continua"),
        LedPattern(id: "Pulso", icon: "bolt.fill", desc: "Parpadeo suave"),
        LedPattern(id: "Flash", icon: "sparkles", desc: "Destello rápido"),
        LedPattern(id: "Onda", icon: "moon.fill", desc: "Efecto onda")
    ]
    
    var body: some View {
        ZStack {
            // 1. Fondo Negro Base
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 2. Luz Ambiental (Glow de fondo)
            // Cambia según el color seleccionado y si está encendido
            if isLedOn {
                selectedColor
                    .opacity(brightness / 100 * 0.2) // Opacidad basada en brillo
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 60)
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // Encabezado
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Iluminación LED")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Controla las luces de tu casco")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    
                    // 1. Foco Principal Interactivo
                    BulbControl(isOn: $isLedOn, brightness: $brightness, color: $selectedColor)
                    
                    // 2. Switch Maestro de Energía
                    PowerSwitchCard(isOn: $isLedOn)
                    
                    // 3. Slider de Brillo
                    BrightnessSliderCard(brightness: $brightness, color: selectedColor, isEnabled: isLedOn)
                    
                    // 4. Selector de Colores
                    ColorGridCard(selectedColor: $selectedColor, colors: ledColors, isEnabled: isLedOn)
                    
                    // 5. Selector de Patrones
                    PatternGridCard(selectedPattern: $selectedPattern, patterns: patterns, activeColor: selectedColor, isEnabled: isLedOn)
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Componentes de UI

// El Foco Grande Circular
struct BulbControl: View {
    @Binding var isOn: Bool
    @Binding var brightness: Double
    @Binding var color: Color
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                // Anillo exterior brillante
                Circle()
                    .stroke(isOn ? color.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 160, height: 160)
                    .shadow(color: isOn ? color : .clear, radius: 20)
                
                // Icono del foco
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isOn ? color : .gray)
                    .shadow(color: isOn ? color.opacity(0.8) : .clear, radius: isOn ? 10 : 0)
            }
            .contentShape(Circle()) // Hace que toda el área sea "tocable"
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                withAnimation(.spring()) {
                    isOn.toggle()
                }
            }
            
            VStack(spacing: 5) {
                Text(isOn ? "Encendido" : "Apagado")
                    .font(.headline)
                    .foregroundColor(isOn ? color : .gray)
                
                Text("Brillo: \(Int(brightness))%")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.darkField)
        .cornerRadius(30)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// Tarjeta de Control de Energía (Switch)
struct PowerSwitchCard: View {
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            // Botón de encendido (Icono)
            ZStack {
                Circle()
                    .stroke(isOn ? Color.neonGreen : Color.gray, lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "power")
                    .foregroundColor(isOn ? Color.neonGreen : Color.gray)
                    .font(.headline)
            }
            
            VStack(alignment: .leading) {
                Text("Control de energía")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(isOn ? "LED activo" : "LED inactivo")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            // Toggle Switch Nativo
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color.neonGreen))
                // FIX: Actualizado para iOS 17+ (dos parámetros: oldValue, newValue)
                .onChange(of: isOn) { _, _ in
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// Tarjeta de Slider de Brillo
struct BrightnessSliderCard: View {
    @Binding var brightness: Double
    var color: Color
    var isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Brillo")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(brightness))%")
                    .font(.headline)
                    .foregroundColor(isEnabled ? color : .gray)
            }
            
            // Slider Personalizado
            Slider(value: $brightness, in: 0...100, step: 1)
                .accentColor(isEnabled ? color : .gray)
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1.0 : 0.5)
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// Grid de Colores
struct ColorGridCard: View {
    @Binding var selectedColor: Color
    let colors: [LedColor]
    var isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Colores predefinidos")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                ForEach(colors) { ledColor in
                    VStack {
                        // Círculo de color
                        ZStack {
                            Circle()
                                .fill(ledColor.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == ledColor.color ? 3 : 0)
                                        .padding(-4) // Borde externo selección
                                )
                                .shadow(color: ledColor.color.opacity(0.5), radius: selectedColor == ledColor.color ? 10 : 0)
                        }
                        .onTapGesture {
                            if isEnabled {
                                withAnimation(.spring()) {
                                    selectedColor = ledColor.color
                                }
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                            }
                        }
                        
                        Text(ledColor.name)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .opacity(isEnabled ? 1.0 : 0.4)
                }
            }
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// Grid de Patrones
struct PatternGridCard: View {
    @Binding var selectedPattern: String
    let patterns: [LedPattern]
    var activeColor: Color
    var isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Patrones de iluminación")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(patterns) { pattern in
                    HStack {
                        Image(systemName: pattern.icon)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(pattern.id)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text(pattern.desc)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(selectedPattern == pattern.id && isEnabled ? activeColor : .gray)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                    // Borde iluminado si está seleccionado
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(selectedPattern == pattern.id && isEnabled ? activeColor : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onTapGesture {
                        if isEnabled {
                            withAnimation {
                                selectedPattern = pattern.id
                            }
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                        }
                    }
                    .opacity(isEnabled ? 1.0 : 0.5)
                }
            }
        }
        .padding(20)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// Preview
struct LedView_Previews: PreviewProvider {
    static var previews: some View {
        LedView()
    }
}
