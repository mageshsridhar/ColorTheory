//
//  OverlayCard.swift
//  ColorTheory
//

import GlassMorphismic
import SwiftUI

/// A black card over a blurred screen, used for help, level recaps and the final screen.
struct OverlayCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            GlassMorphismic(blurIntensity: 20, cornerRadius: 0, shadowRadius: 0, blurStyle: .systemChromeMaterialDark)
                .ignoresSafeArea()
            VStack {
                content
            }
            .multilineTextAlignment(.center)
            .padding()
            .padding(.top)
            .frame(maxWidth: 500)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.black))
            .padding(.horizontal, 16)
        }
        .accessibilityAddTraits(.isModal)
    }
}

/// The thin rule between a card's text and its buttons.
struct CardDivider: View {
    var body: some View {
        Divider().frame(maxWidth: 300)
    }
}
