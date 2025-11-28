import SwiftUI

// MARK: - Modelo de Datos para Gráficos
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - Vista de Métricas
struct MetricasView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // 1. Título
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Métricas")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Seguimiento de rendimiento del casco")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // 2. Grid de 4 Tarjetas
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        MetricCardSmall(icon: "map.fill", title: "Distancia hoy", value: "12.5", unit: "km", percent: "+15%", color: .neonGreen)
                        MetricCardSmall(icon: "clock.fill", title: "Tiempo en ruta", value: "45", unit: "min", percent: "+8%", color: .neonGreen)
                        MetricCardSmall(icon: "bolt.fill", title: "Velocidad prom.", value: "22", unit: "km/h", percent: nil, color: .neonGreen)
                        MetricCardSmall(icon: "battery.100", title: "Batería", value: "87", unit: "%", percent: nil, color: .white)
                    }
                    
                    // 3. Gráfico de Velocidad en el tiempo (INTERACTIVO)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Velocidad en el tiempo")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        InteractiveSpeedChart() // <--- Componente Nuevo
                            .frame(height: 220)
                            .padding()
                            .background(Color.darkField)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                    
                    // 4. Gráfico de Consumo de Batería Semanal (INTERACTIVO)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Consumo de batería semanal")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        InteractiveBatteryChart() // <--- Componente Nuevo
                            .frame(height: 220)
                            .padding()
                            .background(Color.darkField)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                    
                    // 5. Resumen Semanal
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Resumen semanal")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 20) {
                            SummaryRow(title: "Total viajes", value: "23", extra: "+12%")
                            SummaryRow(title: "Distancia total", value: "87.5 km", extra: "+18%")
                            SummaryRow(title: "Tiempo total", value: "5h 32m", extra: "+5%")
                            SummaryRow(title: "Vel. máxima", value: "45 km/h", extra: "Récord!", isRecord: true)
                        }
                    }
                    .padding(25)
                    .background(Color.darkField)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Componentes de Gráficos Interactivos

struct InteractiveSpeedChart: View {
    // Datos simulados para la curva (Puntos de control aproximados)
    let dataPoints: [Double] = [8, 12, 10, 18, 19, 23, 28]
    let labels: [String] = ["8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00"]
    
    @State private var touchLocation: CGPoint = .zero
    @State private var showIndicator: Bool = false
    @State private var currentValue: Double = 0
    @State private var currentLabel: String = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Ejes Y
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 25) {
                            ForEach((0...4).reversed(), id: \.self) { i in
                                Text("\(i * 8)").font(.caption2).foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                    // Ejes X
                    HStack {
                        Text("8:00").font(.caption2).foregroundColor(.gray)
                        Spacer()
                        Text("11:00").font(.caption2).foregroundColor(.gray)
                        Spacer()
                        Text("14:00").font(.caption2).foregroundColor(.gray)
                    }
                    .padding(.leading, 20)
                }
                
                // Área del Gráfico
                let width = geo.size.width - 25 // Ajuste por margen izquierdo
                let height = geo.size.height - 20 // Ajuste por margen inferior
                let chartFrame = CGRect(x: 25, y: 0, width: width, height: height)
                
                // 1. Dibujar la curva (Visual)
                SpeedChartPath(data: dataPoints)
                    .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .frame(width: width, height: height)
                    .offset(x: 25, y: 0)
                
                // Relleno degradado
                SpeedChartPath(data: dataPoints, closePath: true)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.neonGreen.opacity(0.3), Color.neonGreen.opacity(0.0)]), startPoint: .top, endPoint: .bottom))
                    .frame(width: width, height: height)
                    .offset(x: 25, y: 0)
                
                // 2. Capa de Interacción (Drag Gesture)
                Color.white.opacity(0.001) // Invisible pero detectable
                    .frame(width: width, height: height)
                    .offset(x: 25, y: 0)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let locationX = value.location.x - 25 // Ajustar offset
                                // Clamp para no salir del gráfico
                                let clampedX = max(0, min(locationX, width))
                                touchLocation = CGPoint(x: clampedX + 25, y: 0)
                                showIndicator = true
                                
                                // Calcular índice aproximado
                                let step = width / CGFloat(dataPoints.count - 1)
                                let index = Int(round(clampedX / step))
                                if index >= 0 && index < dataPoints.count {
                                    currentValue = dataPoints[index]
                                    currentLabel = labels[index]
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    showIndicator = false
                                }
                            }
                    )
                
                // 3. Indicador Visual (Línea y Tooltip)
                if showIndicator {
                    // Línea Vertical
                    Path { path in
                        path.move(to: CGPoint(x: touchLocation.x, y: 0))
                        path.addLine(to: CGPoint(x: touchLocation.x, y: height))
                    }
                    .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                    
                    // Tooltip Flotante
                    VStack(alignment: .center, spacing: 4) {
                        Text(currentLabel)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(Int(currentValue)) km/h")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.neonGreen)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.neonGreen.opacity(0.5), lineWidth: 1))
                    .position(x: touchLocation.x, y: -20) // Flota encima del dedo
                    .shadow(radius: 5)
                }
            }
        }
        .padding(.leading, 10)
    }
}

// Helper Shape para dibujar curvas suaves
struct SpeedChartPath: Shape {
    let data: [Double]
    var closePath: Bool = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard data.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(data.count - 1)
        let maxY: Double = 32 // Valor máximo del eje Y
        
        // Función auxiliar para mapear valor a coordenada Y (invertida)
        let mapY = { (val: Double) -> CGFloat in
            let ratio = CGFloat(val / maxY)
            return rect.height * (1 - ratio)
        }
        
        let p1 = CGPoint(x: 0, y: mapY(data[0]))
        path.move(to: p1)
        
        // Dibujado simple de curvas Bezier cuadráticas para suavizar
        for i in 1..<data.count {
            let p2 = CGPoint(x: stepX * CGFloat(i), y: mapY(data[i]))
            let midPoint = CGPoint(x: (path.currentPoint!.x + p2.x) / 2, y: (path.currentPoint!.y + p2.y) / 2)
            
            // Usamos curvas cuádricas para simular la suavidad
            // (Para una interpolación perfecta se necesitarían algoritmos más complejos como Catmull-Rom,
            // pero esto es suficiente para UI visual)
            path.addQuadCurve(to: p2, control: CGPoint(x: (path.currentPoint!.x + p2.x)/2, y: path.currentPoint!.y))
            // Simplificación: usaremos addLine para robustez si la curva falla, o control points simples
        }
        
        // Si queremos cerrar el path para el gradiente
        if closePath {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
        
        return path
    }
}

struct InteractiveBatteryChart: View {
    // Datos de la semana
    let data: [ChartDataPoint] = [
        ChartDataPoint(label: "Lun", value: 100),
        ChartDataPoint(label: "Mar", value: 80),
        ChartDataPoint(label: "Mie", value: 90),
        ChartDataPoint(label: "Jue", value: 70),
        ChartDataPoint(label: "Vie", value: 60),
        ChartDataPoint(label: "Sáb", value: 50),
        ChartDataPoint(label: "Dom", value: 87)
    ]
    
    @State private var selectedIndex: Int = 6 // Por defecto Domingo seleccionado
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Ejes Y
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 25) {
                            ForEach((0...4).reversed(), id: \.self) { i in
                                Text("\(i * 25)").font(.caption2).foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                    // Ejes X (Días)
                    HStack {
                        ForEach(0..<data.count, id: \.self) { i in
                            Text(data[i].label)
                                .font(.caption2)
                                .foregroundColor(i == selectedIndex ? .white : .gray)
                                .fontWeight(i == selectedIndex ? .bold : .regular)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.leading, 20)
                }
                
                // Área del Gráfico
                let width = geo.size.width - 25
                let height = geo.size.height - 20
                let stepX = width / CGFloat(data.count - 1)
                
                // Dibujar Líneas
                Path { path in
                    for i in 0..<data.count {
                        let x = CGFloat(i) * stepX
                        let y = height * (1 - CGFloat(data[i].value / 100))
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .offset(x: 25, y: 0)
                
                // Dibujar Puntos Interactivos
                ForEach(0..<data.count, id: \.self) { i in
                    let x = CGFloat(i) * stepX + 25
                    let y = height * (1 - CGFloat(data[i].value / 100))
                    
                    Circle()
                        .fill(Color.neonGreen)
                        .frame(width: i == selectedIndex ? 14 : 8, height: i == selectedIndex ? 14 : 8)
                        .overlay(Circle().stroke(Color.white, lineWidth: i == selectedIndex ? 2 : 0))
                        .position(x: x, y: y)
                        .shadow(color: .neonGreen.opacity(0.5), radius: i == selectedIndex ? 10 : 0)
                }
                
                // Tooltip del elemento seleccionado
                let selectedX = CGFloat(selectedIndex) * stepX + 25
                let selectedY = height * (1 - CGFloat(data[selectedIndex].value / 100))
                
                VStack(alignment: .leading) {
                    Text(data[selectedIndex].label).fontWeight(.bold).foregroundColor(.white)
                    Text("batería : \(Int(data[selectedIndex].value))%").foregroundColor(.neonGreen)
                }
                .padding(10)
                .background(Color.black.opacity(0.9))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                // Lógica inteligente para posicionar el tooltip y que no se salga de pantalla
                .offset(x: selectedIndex > 3 ? -70 : 0, y: -60)
                .position(x: selectedX, y: selectedY)
                .animation(.spring(), value: selectedIndex) // Animación suave al cambiar
                
                // Gestos (Drag y Tap) para seleccionar
                Color.white.opacity(0.001)
                    .frame(width: width, height: height)
                    .offset(x: 25, y: 0)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let locationX = value.location.x
                                let index = Int(round(locationX / stepX))
                                if index >= 0 && index < data.count {
                                    if selectedIndex != index {
                                        // Feedback háptico simple al cambiar
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        withAnimation(.spring()) {
                                            selectedIndex = index
                                        }
                                    }
                                }
                            }
                    )
            }
        }
        .padding(.leading, 10)
    }
}


struct MetricCardSmall: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let percent: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .padding(10)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                Spacer()
                
                if let percent = percent {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.right")
                        Text(percent)
                    }
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.neonGreen)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
        }
        .padding(15)
        .background(Color.darkField)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    let extra: String
    var isRecord: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(extra)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.neonGreen)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isRecord ? Color.neonGreen.opacity(0.1) : Color.clear)
                .cornerRadius(4)
        }
    }
}

struct MetricasView_Previews: PreviewProvider {
    static var previews: some View {
        MetricasView()
    }
}
