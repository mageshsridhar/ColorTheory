//
//  LevelTests.swift
//  ColorTheoryTests
//

import CoreGraphics
import XCTest
@testable import ColorTheory

final class LevelTests: XCTestCase {
    private let screens = [
        CGSize(width: 375, height: 667),    // iPhone SE
        CGSize(width: 402, height: 874),    // iPhone 16 Pro
        CGSize(width: 440, height: 956),    // iPhone 16 Pro Max
        CGSize(width: 1032, height: 1376),  // iPad Pro 13" portrait
        CGSize(width: 1376, height: 1032),  // iPad Pro 13" landscape
        CGSize(width: 320, height: 1032)    // narrow Split View
    ]

    func testEveryPuzzleIsWellFormed() {
        for level in Level.allCases {
            let puzzle = level.board.makePuzzle()
            XCTAssertEqual(puzzle.order.sorted(), Array(puzzle.order.indices), "\(level): ranks must be 0..<n with no repeats")
            for index in puzzle.locked {
                XCTAssertEqual(puzzle.order[index], index, "\(level): locked block \(index) must already be in place")
            }
            XCTAssertFalse(puzzle.isSolved, "\(level) must start unsolved")
        }
    }

    func testEveryPuzzleCanBeSolvedByTapping() {
        for level in Level.allCases {
            var puzzle = level.board.makePuzzle()
            for target in puzzle.order.indices where puzzle.order[target] != target {
                let source = puzzle.order.firstIndex(of: target)!
                XCTAssertEqual(puzzle.tap(source), .selected(source), "\(level)")
                XCTAssertEqual(puzzle.tap(target), .swapped(source, target), "\(level)")
            }
            XCTAssertTrue(puzzle.isSolved, "\(level)")
        }
    }

    func testBoardsFitEveryScreenWidth() {
        for level in Level.allCases {
            for screen in screens {
                let size = level.board.size(for: screen)
                XCTAssertGreaterThan(size.width, 0)
                XCTAssertLessThanOrEqual(size.width, screen.width - 20, "\(level) on \(screen)")
            }
        }
    }

    func testCellSizesAreWholePoints() {
        for level in Level.allCases {
            for screen in screens {
                let cell = level.board.cellSize(for: screen)
                XCTAssertEqual(cell.width, cell.width.rounded(), "\(level) on \(screen)")
                XCTAssertEqual(cell.height, cell.height.rounded(), "\(level) on \(screen)")
            }
        }
    }

    func testNextLevelOrder() {
        XCTAssertEqual(Level.primary.next, .secondary)
        XCTAssertEqual(Level.cool.next, .complementary)
        XCTAssertNil(Level.triadic.next)
        XCTAssertEqual(LevelSection.colorWheel.levels, [.primary, .secondary, .tertiary, .warm, .cool])
        XCTAssertEqual(LevelSection.colorSchemes.levels, [.complementary, .analogous, .triadic])
    }

    func testTertiaryRecapIsAboutTertiaryColors() {
        XCTAssertTrue(Level.tertiary.recap.lowercased().contains("tertiary"))
    }

    func testHexParsing() {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(hex: "#e42535").getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertEqual(red * 255, 0xe4, accuracy: 0.01)
        XCTAssertEqual(green * 255, 0x25, accuracy: 0.01)
        XCTAssertEqual(blue * 255, 0x35, accuracy: 0.01)
        UIColor(hex: "nope").getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        XCTAssertEqual(red, 0.5, accuracy: 0.01)
    }
}

final class ProgressStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "ColorTheoryTests.progress"

    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: suite)
        defaults = UserDefaults(suiteName: suite)
    }

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: suite)
        super.tearDown()
    }

    func testProgressSurvivesARelaunch() {
        let store = ProgressStore(defaults: defaults)
        store.markCompleted(.primary)
        store.markCompleted(.cool)
        let relaunched = ProgressStore(defaults: defaults)
        XCTAssertEqual(relaunched.completed, [.primary, .cool])
        XCTAssertFalse(relaunched.allCompleted)
    }

    func testAllCompletedAndReset() {
        let store = ProgressStore(defaults: defaults)
        Level.allCases.forEach(store.markCompleted)
        XCTAssertTrue(store.allCompleted)
        store.reset()
        XCTAssertTrue(ProgressStore(defaults: defaults).completed.isEmpty)
    }
}
