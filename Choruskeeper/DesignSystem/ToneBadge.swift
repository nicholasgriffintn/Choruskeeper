import SwiftUI

struct ToneBadge: View {
    let tone: Tone
    var count: Int? = nil

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: tone.symbol)
            Text(tone.title)
            if let count {
                Text("\(count)")
                    .fontWeight(.bold)
            }
        }
        .font(.system(.caption, design: .rounded, weight: .semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .foregroundStyle(.white)
        .background(ChorusTheme.color(for: tone).gradient, in: Capsule())
    }
}
