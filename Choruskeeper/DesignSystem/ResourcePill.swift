import SwiftUI

struct ResourcePill: View {
    let symbol: String
    let value: Int
    let tint: Color
    var label: String? = nil

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
            Text(value, format: .number)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .contentTransition(.numericText())
            if let label {
                Text(label)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.ultraThinMaterial, in: Capsule())
        .foregroundStyle(.white)
        .accessibilityElement(children: .combine)
    }
}
