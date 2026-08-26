import SwiftUI

struct SkyArtworkBackground: View {
    var artworkOpacity = 1.0
    var blurRadius = 0.0

    var body: some View {
        ChorusTheme.ink
            .overlay {
                Image("SkyIsles")
                    .resizable()
                    .scaledToFill()
                    .opacity(artworkOpacity)
                    .blur(radius: blurRadius)
            }
            .clipped()
            .ignoresSafeArea()
    }
}
