//
//  ContentView.swift
//  NeoHelmet
//
//  Created by Jonathan Mendoza Acevedo on 27/11/25.
//

import SwiftUI
import SwiftData
import SwiftUI


// MARK: - Vista Principal (Contenedor de Pestañas)
struct ContentView: View {
    @State private var selectedTab = 0
    
    // Configuración de apariencia del TabBar
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().backgroundColor = UIColor.black
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña 1: Inicio
            HomeDashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
                .tag(0)
            
            // Pestaña 2: Métricas (AQUÍ ESTÁ EL CAMBIO)
            // Ahora llamamos a la vista que está en el otro archivo
            MetricasView()
                .tabItem {
                    Label("Métricas", systemImage: "chart.xyaxis.line")
                }
                .tag(1)
            
            // Pestaña 3: LED
            LedView()
                .tabItem {
                    Label("LED", systemImage: "lightbulb.fill")
                }
                .tag(2)
            
            // Pestaña 4: Conexión
            ConexionView()
                .tabItem {
                    Label("Conexión", systemImage: "wifi")
                }
                .tag(3)
            
            // Pestaña 5: Perfil
             PerfilView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(.neonGreen) // Usamos el color de la extensión
        .preferredColorScheme(.dark)
    }
}

// MARK: - Vista del Dashboard (Pantalla Principal)
struct HomeDashboardView: View {
    // Estado para controlar la visibilidad de la alerta
    @State private var showEmergencyAlert = false
    
    var body: some View {
        ZStack {
            // Fondo base
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Contenido Principal
            ScrollView {
                VStack(spacing: 24) {
                    HeaderView()
                    
                    HStack(spacing: 15) {
                        StatusCard(icon: "bolt.fill", title: "Batería", value: "87%", subValue: nil, color: .neonGreen, isBattery: true)
                        StatusCard(icon: "bluetooth", title: "Bluetooth", value: "Conectado", subValue: "NeoHelmet Pro", color: .neonGreen, isBattery: false)
                    }
                    
                    RadarSectionView()
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            // Acción de actualizar (simulada)
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Actualizar estado").fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.neonGreen)
                            .cornerRadius(16)
                        }
                        
                        // Botón que ACTIVA la alerta
                        Button(action: {
                            withAnimation(.spring()) {
                                showEmergencyAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Simular alerta de emergencia").fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                            .shadow(color: .red.opacity(0.5), radius: 10, x: 0, y: 0)
                        }
                    }
                    
                    StatsRowView()
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .blur(radius: showEmergencyAlert ? 10 : 0) // Desenfoca el fondo cuando sale la alerta
            .disabled(showEmergencyAlert) // Deshabilita toques en el fondo
            
            // CAPA DE OSCURECIMIENTO
            if showEmergencyAlert {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation { showEmergencyAlert = false }
                    }
                
                // POPUP DE ALERTA
                EmergencyAlertPopup(isPresented: $showEmergencyAlert)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }
}

// MARK: - Componentes del Dashboard (Emergency, Header, Radar...)

struct EmergencyAlertPopup: View {
    @Binding var isPresented: Bool
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Botón cerrar (X)
            HStack {
                Spacer()
                Button(action: {
                    withAnimation { isPresented = false }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            // Icono animado y Título
            HStack(spacing: 15) {
                // Icono rojo pulsante
                ZStack {
                    Circle()
                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        .frame(width: 60, height: 60)
                        .scaleEffect(isPulsing ? 1.5 : 1.0)
                        .opacity(isPulsing ? 0.0 : 1.0)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 40, height: 40)
                        .shadow(color: .red, radius: 10)
                    
                    Image(systemName: "exclamationmark")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                }
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        isPulsing = true
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text("Alerta de")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Text("Emergencia Detectada")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 10)
            
            // Texto descriptivo
            Text("Posible accidente detectado. Toca para enviar una alerta de emergencia y compartir tu ubicación.")
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            // Botón Grande de Acción
            Button(action: {
                // Lógica para enviar la alerta real
                print("Enviando alerta...")
                withAnimation { isPresented = false }
            }) {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .font(.title3)
                    Text("Enviar alerta de emergencia")
                        .fontWeight(.bold)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.neonGreen, Color.green]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(15)
            }
            .padding(.top, 10)
            
            // Pie de página
            Text("Se notificará a tus contactos de emergencia")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(25)
        .frame(width: 340)
        .background(
            ZStack {
                Color(red: 0.1, green: 0.05, blue: 0.05) // Fondo casi negro rojizo
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1) // Borde rojo sutil
            }
        )
        .cornerRadius(25)
        .shadow(color: Color.red.opacity(0.3), radius: 30, x: 0, y: 0) // Resplandor rojo externo
    }
}

struct HeaderView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Hola, Bienvenido")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                   
                }
                Text("Tu casco está conectado y listo")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle")
                    Text("Sensor activo")
                }
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(.neonGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(Capsule().stroke(Color.neonGreen, lineWidth: 1))
                .padding(.top, 8)
            }
            Spacer()
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.title2)
                    .foregroundColor(.neonGreen)
                    .padding(12)
                    .background(Color.darkField)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                Circle()
                    .fill(Color.neonGreen)
                    .frame(width: 10, height: 10)
                    .offset(x: 2, y: -2)
            }
        }
    }
}

struct StatusCard: View {
    let icon: String
    let title: String
    let value: String
    let subValue: String?
    let color: Color
    let isBattery: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isBattery ? color : .gray)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            if isBattery {
                Text(value)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.neonGreen)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.3)).frame(height: 6)
                        Capsule().fill(Color.neonGreen).frame(width: geo.size.width * 0.87, height: 6)
                    }
                }
                .frame(height: 6)
            } else {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Circle().fill(color).frame(width: 8, height: 8)
                        Text(value)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    if let sub = subValue {
                        Text(sub)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(16)
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color.darkField)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

struct RadarSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .foregroundColor(.neonGreen)
                Text("Proximidad Lineal")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            ZStack {
                Color.darkField
                RadarChartGrid()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .padding(50)
                RadarPolygon()
                    .fill(Color.neonGreen.opacity(0.2))
                    .padding(50)
                RadarPolygon()
                    .stroke(Color.neonGreen, lineWidth: 2)
                    .padding(50)
                VStack {
                    Text("Frontal").font(.caption2).foregroundColor(.gray).offset(y: 30)
                    Spacer()
                    HStack {
                        Text("Izquierda").font(.caption2).foregroundColor(.gray).offset(x: 30)
                        Spacer()
                        Text("Derecha").font(.caption2).foregroundColor(.gray).offset(x: -30)
                    }
                    Spacer()
                    Text("Trasera").font(.caption2).foregroundColor(.gray).offset(y: -30)
                }
                .padding(10)
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Circle().fill(Color.white).frame(width: 6, height: 6)
                            Text("Activo")
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.neonGreen)
                        .cornerRadius(20)
                    }
                    Spacer()
                }
                .padding(20)
            }
            .frame(height: 320)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            Text("Detección de objetos cercanos en metros")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct StatsRowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Estadísticas del día")
                .font(.headline)
                .foregroundColor(.white)
            HStack(spacing: 12) {
                StatItem(icon: "location.north.fill", title: "Viajes", value: "3", color: .neonGreen)
                StatItem(icon: "mappin.and.ellipse", title: "Distancia", value: "12.5 km", color: .neonGreen)
                StatItem(icon: "bolt.fill", title: "Batería", value: "87 %", color: .neonGreen)
            }
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

struct RadarChartGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: CGPoint(x: center.x, y: rect.minY)); path.addLine(to: CGPoint(x: center.x, y: rect.maxY))
        path.move(to: CGPoint(x: rect.minX, y: center.y)); path.addLine(to: CGPoint(x: rect.maxX, y: center.y))
        let steps = 4
        for i in 1...steps {
            let ratio = CGFloat(i) / CGFloat(steps)
            let w = (rect.width / 2) * ratio
            let h = (rect.height / 2) * ratio
            path.move(to: CGPoint(x: center.x, y: center.y - h))
            path.addLine(to: CGPoint(x: center.x + w, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y + h))
            path.addLine(to: CGPoint(x: center.x - w, y: center.y))
            path.closeSubpath()
        }
        return path
    }
}

struct RadarPolygon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let values: [CGFloat] = [0.9, 0.4, 0.7, 0.5]
        let maxRadiusX = rect.width / 2
        let maxRadiusY = rect.height / 2
        path.move(to: CGPoint(x: center.x, y: center.y - (maxRadiusY * values[0])))
        path.addLine(to: CGPoint(x: center.x + (maxRadiusX * values[1]), y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y + (maxRadiusY * values[2])))
        path.addLine(to: CGPoint(x: center.x - (maxRadiusX * values[3]), y: center.y))
        path.closeSubpath()
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
