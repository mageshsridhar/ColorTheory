//
//  ContentView.swift
//  ColorTheory
//
//  Created by Magesh Sridhar on 4/13/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var activeLevel: Level?
    @State private var showInfo = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack {
                            Text("Color Theory").bold().font(.largeTitle).padding()
                            Spacer()
                            Button { showInfo = true } label: {
                                Image(systemName: "info.circle").font(.title).foregroundColor(.white).padding()
                            }
                            .accessibilityLabel("About the game")
                        }
                        ForEach(LevelSection.allCases) { section in
                            HStack {
                                Text(section.rawValue).bold().font(.title)
                                    .padding(section == .colorWheel ? [.horizontal] : [.horizontal, .top])
                                Spacer()
                            }
                            .accessibilityAddTraits(.isHeader)
                            ForEach(section.levels) { level in
                                LevelRow(level: level, completed: progress.isCompleted(level),
                                         height: geo.fullScreenSize.height / 8) {
                                    activeLevel = level
                                }
                            }
                        }
                    }
                }
                if progress.allCompleted { congratulations }
            }
        }
        .sheet(isPresented: $showInfo) {
            InfoView().preferredColorScheme(.dark)
        }
        .fullScreenCover(item: $activeLevel) { level in
            LevelFlow(start: level) { activeLevel = nil }
                .environmentObject(progress)
        }
    }

    private var congratulations: some View {
        OverlayCard {
            Text("Congratulations!").font(.title2).bold().padding()
            Text("You've successfully completed this game! Thanks for playing and hope you learned something new. Tap the button below if you want to play again.")
                .padding()
            CardDivider()
            Button {
                withAnimation(.spring()) { progress.reset() }
            } label: {
                Text("Play Again").padding()
            }
        }
    }
}

private struct LevelRow: View {
    let level: Level
    let completed: Bool
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                LevelIcon(level: level)
                Text(level.title).bold().font(.subheadline)
                Spacer()
                if completed {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 23, weight: .bold)).padding()
                        .accessibilityLabel("Completed")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.levelBackground))
            .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 15)
        .accessibilityElement(children: .combine)
    }
}

/// The small dot arrangement on each level's row.
private struct LevelIcon: View {
    let level: Level

    var body: some View {
        content
            .padding()
            .background(Circle().fill(Palette.iconBackground).frame(minWidth: 60, minHeight: 60))
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        switch level {
        case .primary, .triadic:
            VStack {
                dot(Palette.red, 10)
                HStack { dot(Palette.yellow, 10); dot(Palette.blue, 10) }
            }
        case .secondary:
            VStack {
                HStack { dot(Color.orange, 10); dot(Color.purple, 10) }
                dot(Color.green, 10)
            }
        case .tertiary:
            VStack {
                HStack { dot(Palette.redPurple, 6); dot(Palette.bluePurple, 6) }
                HStack { dot(Palette.blueGreen, 6); dot(Palette.iconBackground, 6); dot(Palette.yellowGreen, 6) }
                HStack { dot(Palette.yellowOrange, 6); dot(Palette.redOrange, 6) }
            }
        case .warm:
            Circle().fill(LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .bottom, endPoint: .top))
                .frame(width: 30, height: 30)
        case .cool:
            Circle().fill(LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .bottom, endPoint: .top))
                .frame(width: 30, height: 30)
        case .complementary:
            HStack { dot(Color.orange, 10); dot(Color.blue, 10) }
        case .analogous:
            HStack { dot(Color.blue, 6); dot(Palette.blueGreen, 6); dot(Color.green, 6) }
        }
    }

    private func dot(_ hex: String, _ size: CGFloat) -> some View { dot(Color(hex: hex), size) }

    private func dot(_ color: Color, _ size: CGFloat) -> some View {
        Circle().fill(color).frame(width: size, height: size)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ProgressStore(defaults: UserDefaults(suiteName: "preview")!))
            .preferredColorScheme(.dark)
    }
}
