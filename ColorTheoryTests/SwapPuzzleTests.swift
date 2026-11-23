//
//  SwapPuzzleTests.swift
//  ColorTheoryTests
//

import XCTest
@testable import ColorTheory

final class SwapPuzzleTests: XCTestCase {
    func testSelectThenSwap() {
        var puzzle = SwapPuzzle(order: [0, 2, 1], locked: [0])
        XCTAssertEqual(puzzle.tap(1), .selected(1))
        XCTAssertEqual(puzzle.selection, 1)
        XCTAssertEqual(puzzle.tap(2), .swapped(1, 2))
        XCTAssertEqual(puzzle.order, [0, 1, 2])
        XCTAssertNil(puzzle.selection)
        XCTAssertTrue(puzzle.isSolved)
    }

    func testTappingTheSameBlockDeselects() {
        var puzzle = SwapPuzzle(order: [1, 0], locked: [])
        XCTAssertEqual(puzzle.tap(0), .selected(0))
        XCTAssertEqual(puzzle.tap(0), .deselected(0))
        XCTAssertEqual(puzzle.order, [1, 0])
        XCTAssertNil(puzzle.selection)
    }

    func testLockedBlocksIgnoreTapsAndKeepTheSelection() {
        var puzzle = SwapPuzzle(order: [0, 2, 1], locked: [0])
        XCTAssertEqual(puzzle.tap(0), .ignored)
        XCTAssertNil(puzzle.selection)
        XCTAssertEqual(puzzle.tap(1), .selected(1))
        XCTAssertEqual(puzzle.tap(0), .ignored)
        XCTAssertEqual(puzzle.selection, 1)
    }

    func testOutOfRangeTapsAreIgnored() {
        var puzzle = SwapPuzzle(order: [1, 0], locked: [])
        XCTAssertEqual(puzzle.tap(-1), .ignored)
        XCTAssertEqual(puzzle.tap(2), .ignored)
    }

    func testSolvedPuzzleIgnoresFurtherTaps() {
        var puzzle = SwapPuzzle(order: [1, 0], locked: [])
        _ = puzzle.tap(0)
        _ = puzzle.tap(1)
        XCTAssertTrue(puzzle.isSolved)
        XCTAssertEqual(puzzle.tap(0), .ignored)
        XCTAssertEqual(puzzle.order, [0, 1])
    }

    func testRapidTapsNeverLoseOrDuplicatePieces() {
        var puzzle = SwapPuzzle(order: Array((0..<9).reversed()), locked: [0, 4, 8])
        var generator = SystemRandomNumberGenerator()
        for _ in 0..<2_000 { _ = puzzle.tap(Int.random(in: -1...9, using: &generator)) }
        XCTAssertEqual(puzzle.order.sorted(), Array(0..<9))
        XCTAssertEqual(puzzle.order[0], 8)
        XCTAssertEqual(puzzle.order[4], 4)
        XCTAssertEqual(puzzle.order[8], 0)
    }
}
