//
//  BoardScene.swift
//  ColorTheory
//

import SpriteKit
import UIKit

/// Draws a level's board and turns taps into puzzle moves. One scene class serves every level.
final class BoardScene: SKScene {
    let board: Board
    private(set) var puzzle: SwapPuzzle
    /// Called on the main thread a second after the winning swap.
    var onSolved: (() -> Void)?

    /// Full-screen size the board is laid out for. Setting it re-lays out the blocks.
    var screenSize: CGSize = .zero {
        didSet { if screenSize != oldValue { layoutTiles() } }
    }

    private let puzzleSlots: [Int]
    /// The block currently in each slot, indexed by slot.
    private var tiles: [SKSpriteNode] = []

    private static let selectSound = SKAction.playSoundFileNamed("click_002.wav", waitForCompletion: false)
    private static let swapSound = SKAction.playSoundFileNamed("click_003.wav", waitForCompletion: false)
    private static let solvedSound = SKAction.playSoundFileNamed("impactMining_002.wav", waitForCompletion: false)
    private static let moveKey = "move"

    init(board: Board) {
        self.board = board
        puzzleSlots = board.puzzleSlots
        puzzle = board.makePuzzle()
        super.init(size: CGSize(width: 1, height: 1))
        scaleMode = .resizeFill
        backgroundColor = .black
        buildTiles()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func didMove(to view: SKView) {
        layoutTiles()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutTiles()
    }

    // MARK: Layout

    private func buildTiles() {
        let lockTexture = UIImage(systemName: "lock.fill").map(SKTexture.init(image:))
        for slot in board.slots {
            let tile = SKSpriteNode(color: UIColor(hex: slot.color), size: .zero)
            tile.isAccessibilityElement = true
            tile.accessibilityLabel = UIColor(hex: slot.color).spokenDescription
            if slot.locked, let lockTexture = lockTexture {
                let lock = SKSpriteNode(texture: lockTexture, size: board.lockSize)
                lock.zPosition = 1
                tile.addChild(lock)
            }
            tiles.append(tile)
            addChild(tile)
        }
        updateAccessibility()
    }

    private var cellSize: CGSize { board.cellSize(for: screenSize) }

    private func center(ofSlot slot: Int) -> CGPoint {
        let cell = cellSize
        let originX = (size.width - cell.width * board.columns) / 2
        let top = (size.height + cell.height * board.rows) / 2
        let position = board.slots[slot]
        return CGPoint(x: originX + (position.column + 0.5) * cell.width,
                       y: top - (position.row + 0.5) * cell.height)
    }

    private func layoutTiles() {
        guard !tiles.isEmpty, screenSize != .zero else { return }
        let cell = cellSize
        for (slot, tile) in tiles.enumerated() {
            tile.removeAction(forKey: Self.moveKey)
            tile.size = cell
            tile.position = center(ofSlot: slot)
        }
    }

    private func slot(at point: CGPoint) -> Int? {
        let cell = cellSize
        return board.slots.indices.first { slot in
            let c = center(ofSlot: slot)
            return CGRect(x: c.x - cell.width / 2, y: c.y - cell.height / 2, width: cell.width, height: cell.height).contains(point)
        }
    }

    // MARK: Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self),
              let slot = slot(at: point),
              let index = puzzleSlots.firstIndex(of: slot) else { return }

        switch puzzle.tap(index) {
        case .ignored:
            return
        case .selected:
            run(Self.selectSound)
            setSelected(tiles[slot], true)
        case .deselected:
            run(Self.swapSound)
            setSelected(tiles[slot], false)
        case let .swapped(a, b):
            run(Self.swapSound)
            swapTiles(puzzleSlots[a], puzzleSlots[b])
            if puzzle.isSolved { finish() }
        }
        updateAccessibility()
    }

    private func setSelected(_ tile: SKSpriteNode, _ selected: Bool) {
        let scale: CGFloat = selected ? 1.06 : 1
        tile.zPosition = selected ? 2 : 0
        switch board.pop {
        case .horizontal: tile.xScale = scale
        case .vertical: tile.yScale = scale
        case .both: tile.setScale(scale)
        }
    }

    private func swapTiles(_ first: Int, _ second: Int) {
        tiles.swapAt(first, second)
        for slot in [first, second] {
            let tile = tiles[slot]
            setSelected(tile, false)
            // A new move replaces any unfinished one, so fast taps can't leave a block between slots.
            tile.run(.move(to: center(ofSlot: slot), duration: 0.15), withKey: Self.moveKey)
        }
        UIAccessibility.post(notification: .announcement, argument: "Swapped")
    }

    private func finish() {
        run(Self.solvedSound)
        run(.sequence([.wait(forDuration: 1), .run { [weak self] in self?.onSolved?() }]))
    }

    // MARK: Accessibility

    private func updateAccessibility() {
        let count = puzzleSlots.count
        for (slot, tile) in tiles.enumerated() {
            guard let index = puzzleSlots.firstIndex(of: slot) else {
                tile.accessibilityValue = "Reference color, locked"
                tile.accessibilityTraits = [.staticText, .notEnabled]
                continue
            }
            let locked = puzzle.locked.contains(index)
            let selected = puzzle.selection == index
            var value = "Position \(index + 1) of \(count)"
            if locked { value += ", locked" }
            if selected { value += ", selected" }
            tile.accessibilityValue = value
            var traits: UIAccessibilityTraits = locked ? [.button, .notEnabled] : .button
            if selected { traits.insert(.selected) }
            tile.accessibilityTraits = traits
        }
    }
}
