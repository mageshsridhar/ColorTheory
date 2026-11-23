//
//  InfoView.swift
//  ColorTheory
//
//  Created by Magesh Sridhar on 4/20/21.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("About the game").font(.title).bold()
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.title).foregroundColor(.white)
                    }
                    .accessibilityLabel("Close")
                }
                .padding()
                Image("colorsbackground").resizable().aspectRatio(contentMode: .fit)
                    .accessibilityHidden(true)
                Text("Photo from Unsplash").font(.caption).padding(.horizontal)
                Text("Hello there! Today we are going to learn color theory in a fun and interactive way. But why do you need to know the color theory? It explains the way you perceive colors and how colors form harmony when they mix or match together. Color Theory shows how colors communicate with each other, and it mainly helps in branding. The following lessons will teach you the concepts in Color Theory, and you will be a master of the perception of colors in no time. So, let's get started.")
                    .padding()
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView().preferredColorScheme(.dark)
    }
}
