//
//  SwapPuzzle.swift
//  ColorTheory
//

/// The rules shared by every level: tap one unlocked piece, then another, to swap them.
/// `order` holds each position's piece rank; the puzzle is solved when the ranks are ascending.
struct SwapPuzzle: Equatable {
    enum TapResult: Equatable {
        /// Locked position, out of range, or the puzzle is already solved.
        case ignored
        case selected(Int)
        case deselected(Int)
        case swapped(Int, Int)
    }

    private(set) var order: [Int]
    let locked: Set<Int>
    private(set) var selection: Int?

    init(order: [Int], locked: Set<Int>) {
        self.order = order
        self.locked = locked
    }

    var isSolved: Bool { order == order.sorted() }

    mutating func tap(_ index: Int) -> TapResult {
        guard !isSolved, order.indices.contains(index), !locked.contains(index) else { return .ignored }
        guard let first = selection else {
            selection = index
            return .selected(index)
        }
        selection = nil
        guard first != index else { return .deselected(index) }
        order.swapAt(first, index)
        return .swapped(first, index)
    }
}
