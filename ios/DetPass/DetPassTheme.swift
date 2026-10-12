import SwiftUI

enum DetPassTheme {
    static let blue = Color(hex: 0x465EFF, opacity: 0.86)
    static let textMuted = Color.black.opacity(0.40)
    static let gradientTop = Color(hex: 0xE7EAFF)
    static let gradientBottom = Color(hex: 0xCAD1FF)
    static let shadow = Color.black.opacity(0.27)

    static let cardGradient = LinearGradient(
        colors: [gradientTop, gradientBottom],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex & 0xFF0000) >> 16) / 255
        let green = Double((hex & 0x00FF00) >> 8) / 255
        let blue = Double(hex & 0x0000FF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

struct DetPassInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .regular, design: .default))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 10)
            .frame(height: 44)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.22), radius: 1, x: 0, y: -1)
    }
}

extension View {
    func detPassInputStyle() -> some View {
        modifier(DetPassInputModifier())
    }
}

struct DetPassPulsingOutline: View {
    var body: some View {
        ZStack {
            DetPassPulseRing(delay: 0.33)
            DetPassPulseRing(delay: 1.8)
        }
    }
}

private struct DetPassPulseRing: View {
    let delay: Double
    @State private var expanded = false

    var body: some View {
        RoundedRectangle(cornerRadius: expanded ? 0 : 12)
            .stroke(DetPassTheme.blue.opacity(expanded ? 0 : 1), lineWidth: expanded ? 0 : 2)
            .scaleEffect(x: expanded ? 1.05 : 1, y: expanded ? 1.10 : 1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 3).repeatForever(autoreverses: false)) {
                        expanded = true
                    }
                }
            }
    }
}
