//
//  LevelView.swift
//  ColorTheory
//

import SpriteKit
import SwiftUI

/// Owns a level's scene and reports when it's solved.
final class LevelSession: ObservableObject {
    let scene: BoardScene
    @Published private(set) var isSolved = false

    init(level: Level) {
        scene = BoardScene(board: level.board)
        scene.onSolved = { [weak self] in
            withAnimation(.easeIn(duration: 0.6)) { self?.isSolved = true }
        }
    }
}

/// Plays levels one after another, starting from the one picked on the home screen.
struct LevelFlow: View {
    @State private var level: Level
    private let onClose: () -> Void

    init(start: Level, onClose: @escaping () -> Void) {
        _level = State(initialValue: start)
        self.onClose = onClose
    }

    var body: some View {
        GeometryReader { geo in
            LevelView(level: level, screen: geo.fullScreenSize, onBack: onClose) {
                if let next = level.next {
                    withAnimation { level = next }
                } else {
                    onClose()
                }
            }
            .id(level)
            .transition(.opacity)
        }
        .preferredColorScheme(.dark)
    }
}

struct LevelView: View {
    let level: Level
    let screen: CGSize
    let onBack: () -> Void
    let onNext: () -> Void

    @EnvironmentObject private var progress: ProgressStore
    @StateObject private var session: LevelSession
    @State private var showHelp = false

    init(level: Level, screen: CGSize, onBack: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.level = level
        self.screen = screen
        self.onBack = onBack
        self.onNext = onNext
        _session = StateObject(wrappedValue: LevelSession(level: level))
    }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    if level == .warm { photo(credit: .above) }
                    board
                    if level == .cool { photo(credit: .below) }
                    details
                    Spacer(minLength: 20)
                }
            }
            if session.isSolved { completionCard }
            if showHelp { helpCard }
        }
        .onAppear { session.scene.screenSize = screen }
        .onChange(of: screen) { session.scene.screenSize = $0 }
        .onChange(of: session.isSolved) { if $0 { progress.markCompleted(level) } }
    }

    // MARK: Sections

    private var header: some View {
        HStack {
            Button(action: onBack) { Text("Back to Levels").padding() }
            Spacer()
            Button {
                withAnimation(.spring()) { showHelp = true }
            } label: {
                Text("How to Play").padding()
            }
        }
        .padding(.horizontal)
    }

    private var board: some View {
        let size = level.board.size(for: screen)
        return SpriteView(scene: session.scene)
            .frame(maxWidth: .infinity)
            .frame(height: size.height + 2 * level.board.padding(for: screen))
    }

    private enum CreditPlacement { case above, below }

    @ViewBuilder
    private func photo(credit placement: CreditPlacement) -> some View {
        if let photo = level.photo {
            let width = level.board.size(for: screen).width
            let credit = HStack {
                Spacer()
                Text(photo.credit).font(.caption)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 6)

            if placement == .above { credit }
            Image(photo.name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: photo.height(screen))
                .clipped()
                .accessibilityHidden(true)
            if placement == .below { credit }
        }
    }

    @ViewBuilder
    private var details: some View {
        HStack {
            Text(level.title).bold().font(.title).padding(.horizontal, 32).padding(.top, 8)
            Spacer()
        }
        if let wheel = level.wheel, wheel.dimsOthers {
            // Warm and cool: the half-highlighted wheel beside the explanation.
            HStack(spacing: 16) {
                ColorWheel(highlight: wheel).frame(width: 120, height: 120)
                Text(level.paragraphs.joined(separator: "\n\n")).font(.callout)
                Spacer(minLength: 0)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.levelBackground))
            .padding(.horizontal)
            .padding(.top, 10)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(level.paragraphs, id: \.self) { Text($0).fixedSize(horizontal: false, vertical: true) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
            if let wheel = level.wheel {
                ColorWheel(highlight: wheel)
                    .frame(maxWidth: 260)
                    .padding()
            }
        }
    }

    // MARK: Cards

    private var helpCard: some View {
        OverlayCard {
            Text("How to Play").font(.title2).bold().padding()
            Text("Tap on one unlocked color and tap on another to swap their positions.")
            Text("Objective").font(.title2).bold().padding()
            Text(level.objective)
            CardDivider()
            Button {
                withAnimation(.spring()) { showHelp = false }
            } label: {
                Text("Close").padding()
            }
        }
    }

    private var completionCard: some View {
        OverlayCard {
            Text("Level Completed!").font(.largeTitle).bold()
            HStack {
                ForEach(level.recapDots, id: \.self) { dot in
                    Circle().fill(dot.color).frame(width: dot.size, height: dot.size)
                }
            }
            .accessibilityHidden(true)
            Text("Recap").font(.title).padding()
            Text(level.recap)
            CardDivider()
            Button(action: onNext) {
                Text(level.next == nil ? "Finish" : "Next Level").padding()
            }
            Button(action: onBack) {
                Text("Back to Levels").font(.callout).padding(.bottom)
            }
        }
    }
}

extension GeometryProxy {
    /// The whole screen, including the safe areas. Block sizes are based on this, as before.
    var fullScreenSize: CGSize {
        CGSize(width: size.width + safeAreaInsets.leading + safeAreaInsets.trailing,
               height: size.height + safeAreaInsets.top + safeAreaInsets.bottom)
    }
}

struct LevelView_Previews: PreviewProvider {
    static var previews: some View {
        LevelFlow(start: .primary, onClose: {})
            .environmentObject(ProgressStore(defaults: UserDefaults(suiteName: "preview")!))
    }
}
