//
//  Board.swift
//  ColorTheory
//

import CoreGraphics

/// Where a level's colored blocks sit and how big they are.
struct Board {
    enum PopAxis { case horizontal, vertical, both }

    struct Slot {
        /// Grid position of the block's top-left corner, in cells.
        let column: CGFloat
        let row: CGFloat
        let color: String
        let locked: Bool
        /// Order in the solved puzzle, or nil for a fixed reference block that isn't part of the puzzle.
        let rank: Int?
    }

    let slots: [Slot]
    let columns: CGFloat
    let rows: CGFloat
    /// Which way a selected block grows.
    let pop: PopAxis
    let lockSize: CGSize
    /// Cell size for a given full-screen size, before fitting to the screen width.
    let preferredCellSize: (CGSize) -> CGSize

    /// Slot indices that take part in the puzzle, in puzzle order.
    var puzzleSlots: [Int] { slots.indices.filter { slots[$0].rank != nil } }

    func makePuzzle() -> SwapPuzzle {
        let indices = puzzleSlots
        let locked = indices.enumerated().filter { slots[$0.element].locked }.map(\.offset)
        return SwapPuzzle(order: indices.map { slots[$0].rank! }, locked: Set(locked))
    }

    /// Whole-point cell size that keeps the board inside the screen width with a margin.
    func cellSize(for screen: CGSize) -> CGSize {
        var cell = preferredCellSize(screen)
        let maxWidth = max(screen.width - 20, 1)
        if cell.width * columns > maxWidth {
            let scale = maxWidth / (cell.width * columns)
            cell = CGSize(width: cell.width * scale, height: cell.height * scale)
        }
        return CGSize(width: max(cell.width.rounded(.down), 1), height: max(cell.height.rounded(.down), 1))
    }

    func size(for screen: CGSize) -> CGSize {
        let cell = cellSize(for: screen)
        return CGSize(width: cell.width * columns, height: cell.height * rows)
    }

    /// Space around the board so a selected block can grow without being clipped.
    func padding(for screen: CGSize) -> CGFloat {
        (cellSize(for: screen).height * 0.03).rounded(.up) + 2
    }
}

extension Board {
    /// Rows from top to bottom, each centered horizontally. Every color must have a rank.
    static func rows(_ rows: [[String]], ranks: [String: Int], pop: PopAxis, lockSize: CGSize,
                     locked: (_ row: Int, _ index: Int, _ count: Int) -> Bool,
                     cellSize: @escaping (CGSize) -> CGSize) -> Board {
        let widest = rows.map(\.count).max() ?? 0
        var slots: [Slot] = []
        for (r, row) in rows.enumerated() {
            let offset = CGFloat(widest - row.count) / 2
            for (i, color) in row.enumerated() {
                slots.append(Slot(column: offset + CGFloat(i), row: CGFloat(r), color: color,
                                  locked: locked(r, i, row.count), rank: rank(of: color, in: ranks)))
            }
        }
        return Board(slots: slots, columns: CGFloat(widest), rows: CGFloat(rows.count),
                     pop: pop, lockSize: lockSize, preferredCellSize: cellSize)
    }

    /// Columns from left to right, each listed top to bottom. Columns in `fixedColumns` are locked
    /// reference blocks that aren't part of the puzzle.
    static func columns(_ columns: [[String]], ranks: [String: Int], fixedColumns: Set<Int> = [], pop: PopAxis,
                        lockSize: CGSize, locked: (_ column: Int, _ index: Int, _ count: Int) -> Bool,
                        cellSize: @escaping (CGSize) -> CGSize) -> Board {
        var slots: [Slot] = []
        for (c, column) in columns.enumerated() {
            let fixed = fixedColumns.contains(c)
            for (i, color) in column.enumerated() {
                slots.append(Slot(column: CGFloat(c), row: CGFloat(i), color: color,
                                  locked: fixed || locked(c, i, column.count),
                                  rank: fixed ? nil : rank(of: color, in: ranks)))
            }
        }
        return Board(slots: slots, columns: CGFloat(columns.count), rows: CGFloat(columns.map(\.count).max() ?? 0),
                     pop: pop, lockSize: lockSize, preferredCellSize: cellSize)
    }

    private static func rank(of color: String, in ranks: [String: Int]) -> Int {
        guard let rank = ranks[color] else { preconditionFailure("No rank for \(color)") }
        return rank
    }
}
