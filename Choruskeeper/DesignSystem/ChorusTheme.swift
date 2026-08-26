import SwiftUI

enum ChorusTheme {
    static let ink = Color(red: 0.035, green: 0.075, blue: 0.15)
    static let deepBlue = Color(red: 0.04, green: 0.13, blue: 0.26)
    static let peacock = Color(red: 0.07, green: 0.52, blue: 0.50)
    static let mist = Color(red: 0.78, green: 0.89, blue: 0.90)
    static let cream = Color(red: 0.98, green: 0.94, blue: 0.83)
    static let brass = Color(red: 0.95, green: 0.69, blue: 0.25)
    static let coral = Color(red: 0.98, green: 0.39, blue: 0.30)

    static func color(for tone: Tone) -> Color {
        switch tone {
        case .grove: Color(red: 0.35, green: 0.72, blue: 0.40)
        case .tide: Color(red: 0.20, green: 0.68, blue: 0.82)
        case .ember: coral
        case .gale: Color(red: 0.62, green: 0.59, blue: 0.93)
        }
    }
}

struct ChorusCard: ViewModifier {
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(ChorusTheme.deepBlue.opacity(0.88))
                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
                    .shadow(color: .black.opacity(0.24), radius: 18, y: 10)
            )
    }
}

extension View {
    func chorusCard(padding: CGFloat = 18) -> some View {
        modifier(ChorusCard(padding: padding))
    }

    func displayTitle() -> some View {
        font(.system(.largeTitle, design: .serif, weight: .bold))
            .tracking(-0.7)
    }
}
