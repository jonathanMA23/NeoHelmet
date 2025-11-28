import SwiftUI

// Estados del proceso de conexión
enum ConnectionState {
    case scanning       // Escáner QR
    case searching      // Radar buscando
    case devicesFound   // <--- NUEVO: Lista de dispositivos encontrados
    case paired         // Éxito / Detalles
}

struct ConexionView: View {
    // Estado actual de la vista
    @State private var currentState: ConnectionState = .scanning
    @State private var isAnimatingScanner = false
    @State private var radarPulse = false
    
    // Control para simular encontrar múltiples dispositivos la segunda vez
    @State private var shouldFindMultiple = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Título dinámico según el estado
                Text(titleForState)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .multilineTextAlignment(.center)
                
                Text(subtitleForState)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Contenido Central Cambiante
                ZStack {
                    if currentState == .scanning {
                        QRScannerView(isAnimating: $isAnimatingScanner)
                            .transition(.opacity.combined(with: .scale))
                    } else if currentState == .searching {
                        RadarSearchingView(isPulsing: $radarPulse)
                            .transition(.opacity.combined(with: .scale))
                    } else if currentState == .devicesFound {
                        // NUEVA VISTA: Lista de dispositivos
                        DevicesFoundView {
                            connectDevice()
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else if currentState == .paired {
                        PairedSuccessView(onAddOtherDevice: {
                            // Acción para reiniciar el flujo buscando múltiples
                            restartFlowForMultipleDevices()
                        })
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Botón de Acción Principal (Oculto en selección de lista para usar los botones de la lista)
                if currentState != .devicesFound {
                    Button(action: advanceState) {
                        HStack {
                            if currentState == .scanning {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Escanear dispositivo")
                            } else if currentState == .searching {
                                Text("Buscando dispositivos cercanos...")
                            } else if currentState == .paired {
                                Text("Dispositivo conectado y sincronizado")
                            }
                        }
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(currentState == .searching ? .gray : (currentState == .paired ? .neonGreen : .black))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            currentState == .scanning ? Color.neonGreen :
                            currentState == .searching ? Color.darkField :
                            Color.darkField
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(currentState == .paired ? Color.neonGreen.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                    .disabled(currentState == .searching || currentState == .paired)
                }
            }
        }
        .onAppear {
            isAnimatingScanner = true
        }
    }
    
    // Textos dinámicos
    var titleForState: String {
        switch currentState {
        case .scanning: return "Emparejar NeoHelmet"
        case .searching: return "Buscando..."
        case .devicesFound: return "Dispositivos cercanos"
        case .paired: return "NeoHelmet Conectado"
        }
    }
    
    var subtitleForState: String {
        switch currentState {
        case .scanning: return "Escanea el código QR de tu casco"
        case .searching: return "Acerca tu casco al teléfono"
        case .devicesFound: return "Selecciona tu dispositivo para vincular"
        case .paired: return "Conexión establecida correctamente"
        }
    }
    
    // Lógica para simular el avance de pantallas
    func advanceState() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentState == .scanning {
                currentState = .searching
                
                // Simular búsqueda
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        if self.shouldFindMultiple {
                            // Si venimos de "Agregar otro", mostramos lista
                            self.currentState = .devicesFound
                        } else {
                            // Flujo normal directo
                            self.connectDevice()
                        }
                    }
                }
            } else if currentState == .paired {
                // Reset simple
                currentState = .scanning
                shouldFindMultiple = false
            }
        }
    }
    
    // Función para conectar (Ir a éxito)
    func connectDevice() {
        let successGen = UINotificationFeedbackGenerator()
        successGen.notificationOccurred(.success)
        withAnimation {
            currentState = .paired
        }
    }
    
    // Función llamada al dar click en "Emparejar otro dispositivo"
    func restartFlowForMultipleDevices() {
        withAnimation {
            shouldFindMultiple = true // Activamos la bandera
            currentState = .scanning  // Volvemos al inicio
        }
    }
}

// MARK: - Subvistas por Estado

// NUEVA VISTA: LISTA DE DISPOSITIVOS ENCONTRADOS
struct DevicesFoundView: View {
    var onSelect: () -> Void
    
    let devices = [
        (name: "NeoHelmet Sport", signal: 4, icon: "bicycle"),
        (name: "NeoHelmet Urban X", signal: 3, icon: "figure.outdoor.cycle"),
        (name: "NeoHelmet Pro v2", signal: 5, icon: "star.fill")
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            ForEach(devices, id: \.name) { device in
                Button(action: onSelect) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.darkField)
                                .frame(width: 50, height: 50)
                            Image(systemName: device.icon)
                                .foregroundColor(.neonGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Señal fuerte")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Indicador de señal
                        HStack(spacing: 2) {
                            ForEach(0..<5) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(i < device.signal ? Color.neonGreen : Color.gray.opacity(0.3))
                                    .frame(width: 3, height: CGFloat(6 + (i * 3)))
                            }
                        }
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                    .padding()
                    .background(Color.darkField.opacity(0.5))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal, 25)
    }
}

// 1. VISTA DE ESCÁNER QR
struct QRScannerView: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 280, height: 280)
            
            QRCornerShape()
                .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                .frame(width: 280, height: 280)
                .shadow(color: .neonGreen.opacity(0.6), radius: 10)
            
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.neonGreen.opacity(0.3))
            
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [.clear, .neonGreen, .clear]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 260, height: 3)
                .offset(y: isAnimating ? 130 : -130)
                .animation(Animation.linear(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                .shadow(color: .neonGreen, radius: 5)
        }
        .onAppear { isAnimating.toggle() }
    }
}

struct QRCornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let length: CGFloat = 40
        
        path.move(to: CGPoint(x: 0, y: length)); path.addLine(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: length, y: 0))
        path.move(to: CGPoint(x: rect.width - length, y: 0)); path.addLine(to: CGPoint(x: rect.width, y: 0)); path.addLine(to: CGPoint(x: rect.width, y: length))
        path.move(to: CGPoint(x: rect.width, y: rect.height - length)); path.addLine(to: CGPoint(x: rect.width, y: rect.height)); path.addLine(to: CGPoint(x: rect.width - length, y: rect.height))
        path.move(to: CGPoint(x: length, y: rect.height)); path.addLine(to: CGPoint(x: 0, y: rect.height)); path.addLine(to: CGPoint(x: 0, y: rect.height - length))
        
        return path
    }
}

// 2. VISTA DE RADAR (BUSCANDO)
struct RadarSearchingView: View {
    @Binding var isPulsing: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                Circle()
                    .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
                    .frame(width: CGFloat(100 + (i * 80)), height: CGFloat(100 + (i * 80)))
            }
            
            Circle()
                .stroke(Color.neonGreen, lineWidth: 2)
                .frame(width: isPulsing ? 350 : 50, height: isPulsing ? 350 : 50)
                .opacity(isPulsing ? 0 : 1)
                .animation(Animation.easeOut(duration: 2).repeatForever(autoreverses: false), value: isPulsing)
            
            ZStack {
                Circle()
                    .stroke(Color.neonGreen.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isPulsing ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isPulsing)
            }
        }
        .onAppear { isPulsing = true }
    }
}

// 3. VISTA DE EMPAREJADO (ÉXITO)
struct PairedSuccessView: View {
    // Callback para agregar otro dispositivo
    var onAddOtherDevice: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle().fill(Color.neonGreen.opacity(0.1)).frame(width: 150, height: 150)
                Circle().stroke(Color.neonGreen, lineWidth: 3).frame(width: 120, height: 120)
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.neonGreen)
            }
            .padding(.top, 20)
            
            VStack(spacing: 10) {
                Text("Casco vinculado").font(.title2).fontWeight(.bold).foregroundColor(.white)
                HStack {
                    Text("correctamente").font(.title2).fontWeight(.bold).foregroundColor(.white)
                    Image(systemName: "checkmark.square.fill").foregroundColor(.neonGreen)
                }
                Text("NeoHelmet Pro está listo para usar").foregroundColor(.gray).font(.subheadline)
            }
            
            VStack(spacing: 15) {
                DetailRow(label: "Modelo", value: "NeoHelmet Pro", isHighlight: true)
                DetailRow(label: "Serie", value: "NH-2024-X7", isHighlight: true)
                DetailRow(label: "Batería", value: "87%", isHighlight: true, isGreen: true)
                DetailRow(label: "Firmware", value: "v2.4.1", isHighlight: true)
            }
            .padding(25)
            .background(Color.darkField)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 30)
            
            Button(action: onAddOtherDevice) {
                Text("Emparejar otro dispositivo")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(.neonGreen)
            }
            .padding(.top, 10)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var isHighlight: Bool = false
    var isGreen: Bool = false
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).fontWeight(isHighlight ? .bold : .regular).foregroundColor(isGreen ? .neonGreen : .white)
        }
    }
}

struct ConexionView_Previews: PreviewProvider {
    static var previews: some View {
        ConexionView()
    }
}
