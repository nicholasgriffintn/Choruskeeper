import SwiftUI

struct CadentArtwork: View {
    let species: CadentSpecies
    var isDiscovered = true

    var body: some View {
        Image(species.assetName)
            .resizable()
            .scaledToFit()
            .saturation(isDiscovered ? 1 : 0)
            .brightness(isDiscovered ? 0 : -0.72)
            .contrast(isDiscovered ? 1 : 1.3)
            .shadow(color: isDiscovered ? ChorusTheme.color(for: species.affinity).opacity(0.35) : .clear, radius: 16)
            .accessibilityLabel(isDiscovered ? species.name : "Undiscovered Cadent")
    }
}
