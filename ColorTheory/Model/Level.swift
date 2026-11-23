//
//  Level.swift
//  ColorTheory
//

import SwiftUI

enum LevelSection: String, CaseIterable, Identifiable {
    case colorWheel = "Color Wheel"
    case colorSchemes = "Color Schemes"

    var id: String { rawValue }
    var levels: [Level] { Level.allCases.filter { $0.section == self } }
}

/// Everything that differs between levels: the text, the board and the extras.
enum Level: String, CaseIterable, Identifiable {
    case primary, secondary, tertiary, warm, cool, complementary, analogous, triadic

    struct RecapDot: Hashable {
        let color: Color
        let size: CGFloat
    }

    struct Photo {
        let name: String
        let credit: String
        let height: (CGSize) -> CGFloat
    }

    var id: String { rawValue }

    var section: LevelSection {
        switch self {
        case .complementary, .analogous, .triadic: return .colorSchemes
        default: return .colorWheel
        }
    }

    /// The level after this one, or nil for the last level.
    var next: Level? {
        let all = Level.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return nil }
        return all[index + 1]
    }

    var title: String {
        switch self {
        case .primary: return "Primary Colors"
        case .secondary: return "Secondary Colors"
        case .tertiary: return "Tertiary Colors"
        case .warm: return "Warm Colors"
        case .cool: return "Cool Colors"
        case .complementary: return "Complementary Colors"
        case .analogous: return "Analogous Colors"
        case .triadic: return "Triadic Colors"
        }
    }

    var paragraphs: [String] {
        switch self {
        case .primary:
            return ["Primary colors are a set of colors which can be used to make a range of colors.",
                    "They are ❤️ Red, 💛 Yellow and 💙 Blue."]
        case .secondary:
            return ["Secondary colors are obtained by mixing two of the primary colors.",
                    "❤️ Red + 💛 Yellow = 🧡 Orange",
                    "💛 Yellow + 💙 Blue = 💚 Green",
                    "❤️ Red + 💙 Blue = 💜 Purple"]
        case .tertiary:
            return ["Tertiary colors are made by mixing one primary and one secondary color that are adjacent to each other.",
                    "💜 Purple + ❤️ Red = Red-Purple",
                    "💙 Blue + 💜 Purple = Blue-Purple",
                    "💚 Green + 💙 Blue = Blue-Green",
                    "💛 Yellow + 💚 Green = Yellow-Green",
                    "🧡 Orange + 💛 Yellow = Yellow-Orange",
                    "❤️ Red + 🧡 Orange = Red-Orange"]
        case .warm:
            return ["Warm colors are generally associated with energy, brightness, and action. Draw a line through the center of the color wheel and you'll separate the warm colors."]
        case .cool:
            return ["The other half of the color wheel represents the cool colors. They are associated with calmness, serenity, and peace. The temperature of colors in your design plays a vital role in your message."]
        case .complementary:
            return ["Complementary colors are opposites on the color wheel—red and green, for example. There’s a sharp contrast between the two colors so they can make imagery pop, but overusing them can get tiresome."]
        case .analogous:
            return ["Analogous colors are colors adjacent to one another on the color wheel—for example, red, orange, and yellow. When creating an analogous color scheme, one color will dominate, one will support, and another will accent."]
        case .triadic:
            return ["Triadic colors are evenly spaced around the color wheel and tend to be very bright and dynamic. Using a triadic color scheme in your design creates visual contrast and harmony simultaneously, making each item stand out while making the overall image pop."]
        }
    }

    var objective: String {
        switch self {
        case .primary: return "Arrange the colors in such a way that they transition smoothly from top to bottom."
        case .secondary, .warm, .cool: return "Arrange the colors in such a way that they transition smoothly from left to right."
        case .tertiary: return "Arrange the colors in such a way that the middle color is a mix of the colors on the right and left."
        case .complementary: return "Arrange the colors on the diagonal so that the colors in each row transition from left to right."
        case .analogous: return "Arrange the colors in such a way that they transition smoothly from left to right in each row."
        case .triadic: return "Arrange the colors along the triangle's border so that they transition smoothly from left to right in each row."
        }
    }

    var recap: String {
        switch self {
        case .primary: return "Primary colors are red, yellow and blue."
        case .secondary: return "Secondary colors are orange, purple and green."
        case .tertiary: return "Tertiary colors mix a primary color with the secondary color next to it."
        case .warm: return "Warm colors are used for bright and energetic designs."
        case .cool: return "Cool colors are used for calm and soothing designs."
        case .complementary: return "Complementary colors are opposite to each other on the color wheel."
        case .analogous: return "Analogous colors are adjacent colors on the color wheel."
        case .triadic: return "Triadic colors are equally spaced from one another on the color wheel."
        }
    }

    var recapDots: [RecapDot] {
        switch self {
        case .primary:
            return [RecapDot(color: Color(hex: Palette.red), size: 40), RecapDot(color: Color(hex: Palette.yellow), size: 50),
                    RecapDot(color: Color(hex: Palette.blue), size: 40)]
        case .secondary:
            return [RecapDot(color: Color(hex: Palette.orange), size: 40), RecapDot(color: Color(hex: Palette.purple), size: 50),
                    RecapDot(color: Color(hex: Palette.green), size: 40)]
        case .tertiary:
            return [RecapDot(color: Color(hex: Palette.redPurple), size: 40), RecapDot(color: Color(hex: Palette.yellowOrange), size: 50),
                    RecapDot(color: Color(hex: Palette.blueGreen), size: 40)]
        case .warm: return [RecapDot(color: .orange, size: 40), RecapDot(color: .red, size: 40)]
        case .cool: return [RecapDot(color: .blue, size: 40), RecapDot(color: .purple, size: 40)]
        case .complementary: return [RecapDot(color: .orange, size: 40), RecapDot(color: .blue, size: 40)]
        case .analogous:
            return [RecapDot(color: .blue, size: 40), RecapDot(color: Color(hex: Palette.blueGreen), size: 50),
                    RecapDot(color: .green, size: 40)]
        case .triadic: return [RecapDot(color: .red, size: 40), RecapDot(color: .yellow, size: 50), RecapDot(color: .blue, size: 40)]
        }
    }

    /// Photo shown above (warm) or below (cool) the board.
    var photo: Photo? {
        switch self {
        case .warm: return Photo(name: "warmcolors", credit: "Photo by Birger Strahl on Unsplash", height: { $0.height / 3.5 })
        case .cool: return Photo(name: "coolcolors", credit: "Photo by David Becker on Unsplash", height: { $0.height / 4.6 })
        default: return nil
        }
    }

    var wheel: ColorWheel.Highlight? {
        switch self {
        case .warm: return .warm
        case .cool: return .cool
        case .complementary: return .complementary
        case .analogous: return .analogous
        case .triadic: return .triadic
        default: return nil
        }
    }

    // MARK: Boards

    var board: Board {
        switch self {
        case .primary:
            let colors = ["#e42535", "#85d27e", "#f69133", "#0090b1", "#f8e16c", "#f8ba49", "#00b5a2", "#f0632e", "#336699"]
            let ranks = ["#e42535": 0, "#f0632e": 1, "#f69133": 2, "#f8ba49": 3, "#f8e16c": 4,
                         "#85d27e": 5, "#00b5a2": 6, "#0090b1": 7, "#336699": 8]
            return .rows(colors.map { [$0] }, ranks: ranks, pop: .horizontal, lockSize: CGSize(width: 10, height: 14),
                         locked: { row, _, _ in row % 4 == 0 },
                         cellSize: { CGSize(width: $0.width - 60, height: ($0.height / 13).rounded()) })
        case .secondary:
            let colors = ["#8a1c7c", "#938d00", "#5d891a", "#dd3560", "#fe8134", "#f4594b", "#b91d71", "#c98a00", "#178138"]
            let ranks = ["#8a1c7c": 0, "#b91d71": 1, "#dd3560": 2, "#f4594b": 3, "#fe8134": 4,
                         "#c98a00": 5, "#938d00": 6, "#5d891a": 7, "#178138": 8]
            return .rows([colors], ranks: ranks, pop: .vertical, lockSize: CGSize(width: 12, height: 16),
                         locked: { _, index, _ in index % 4 == 0 },
                         cellSize: { CGSize(width: ($0.width / 9).rounded(), height: ($0.height / 2.5).rounded()) })
        case .tertiary:
            let left = [Palette.red, Palette.purple, Palette.blue, Palette.green, Palette.yellow, Palette.orange]
            let middle = [Palette.blueGreen, Palette.redPurple, Palette.redOrange, Palette.yellowOrange, Palette.bluePurple, Palette.yellowGreen]
            let right = [Palette.purple, Palette.blue, Palette.green, Palette.yellow, Palette.orange, Palette.red]
            let ranks = [Palette.redPurple: 0, Palette.bluePurple: 1, Palette.blueGreen: 2,
                         Palette.yellowGreen: 3, Palette.yellowOrange: 4, Palette.redOrange: 5]
            return .columns([left, middle, right], ranks: ranks, fixedColumns: [0, 2], pop: .both,
                            lockSize: CGSize(width: 12, height: 16), locked: { _, _, _ in false },
                            cellSize: { let side = ($0.height / 8).rounded(); return CGSize(width: side, height: side) })
        case .warm:
            let colors = ["#f35932", "#f87a31", "#fc9837", "#fa8933", "#f66a31", "#fda63c", "#fdb444"]
            let ranks = ["#f35932": 0, "#f66a31": 1, "#f87a31": 2, "#fa8933": 3, "#fc9837": 4, "#fda63c": 5, "#fdb444": 6]
            return .rows([colors], ranks: ranks, pop: .vertical, lockSize: CGSize(width: 8, height: 10),
                         locked: { _, index, count in index == 0 || index == count - 1 },
                         cellSize: Level.tallCell(columns: 8))
        case .cool:
            let colors = ["#8a1c7c", "#7657ac", "#5d80c9", "#686dbd", "#823e97", "#5992d0", "#5ea3d4"]
            let ranks = ["#8a1c7c": 0, "#823e97": 1, "#7657ac": 2, "#686dbd": 3, "#5d80c9": 4, "#5992d0": 5, "#5ea3d4": 6]
            return .rows([colors], ranks: ranks, pop: .vertical, lockSize: CGSize(width: 8, height: 10),
                         locked: { _, index, count in index == 0 || index == count - 1 },
                         cellSize: Level.tallCell(columns: 8))
        case .complementary:
            let columns = [["#4e2b76", "#e95a28", "#f28923", "#f7b92d", "#e6433e"],
                           ["#bd0b48", "#1f93a2", "#e64452", "#81b630", "#a7cf69"],
                           ["#97095b", "#a2156a", "#65267e", "#28a970", "#71bf88"],
                           ["#6a1665", "#ce1847", "#714a9a", "#c13b88", "#4bb6a8"],
                           ["#44b8c7", "#26408c", "#1364a7", "#1d88b5", "#f6ee66"]]
            let ranks = ["#e6433e": 0, "#e95a28": 1, "#f28923": 2, "#f7b92d": 3, "#f6ee66": 4,
                         "#bd0b48": 5, "#ce1847": 6, "#e64452": 7, "#81b630": 8, "#a7cf69": 9,
                         "#97095b": 10, "#a2156a": 11, "#c13b88": 12, "#28a970": 13, "#71bf88": 14,
                         "#6a1665": 15, "#65267e": 16, "#714a9a": 17, "#1f93a2": 18, "#4bb6a8": 19,
                         "#4e2b76": 20, "#26408c": 21, "#1364a7": 22, "#1d88b5": 23, "#44b8c7": 24]
            // Only the two diagonals move.
            return .columns(columns, ranks: ranks, pop: .both, lockSize: CGSize(width: 8, height: 10),
                            locked: { column, index, count in index != column && index != count - 1 - column },
                            cellSize: { let side = ($0.height / 11).rounded(); return CGSize(width: side, height: side) })
        case .analogous:
            let rows = [["#f8e16c", "#008a6f", "#5a400e", "#1f536f"],
                        ["#8eb348", "#52600e", "#4ca05e", "#005666", "#008b8e", "#233d4d"],
                        ["#178138", "#007072", "#6abf7d", "#4c2719"]]
            let ranks = ["#f8e16c": 0, "#6abf7d": 1, "#008b8e": 2, "#1f536f": 3, "#8eb348": 4, "#4ca05e": 5, "#008a6f": 6,
                         "#007072": 7, "#005666": 8, "#233d4d": 9, "#178138": 10, "#52600e": 11, "#5a400e": 12, "#4c2719": 13]
            return .rows(rows, ranks: ranks, pop: .both, lockSize: CGSize(width: 8, height: 10),
                         locked: { _, index, count in index == 0 || index == count - 1 },
                         cellSize: Level.tallCell(columns: 7))
        case .triadic:
            let rows = [["#e32535"],
                        ["#156fa0", "#e6475c", "#c63383"],
                        ["#f6ac3f", "#ef805d", "#e8627d", "#be5898", "#24a690"],
                        ["#f7e06b", "#7e58a2", "#5bb673", "#ed7231", "#9fcb5a", "#1f8da3", "#34669a"]]
            let ranks = ["#e32535": 0, "#ed7231": 1, "#e6475c": 2, "#c63383": 3, "#f6ac3f": 4, "#ef805d": 5, "#e8627d": 6,
                         "#be5898": 7, "#7e58a2": 8, "#f7e06b": 9, "#9fcb5a": 10, "#5bb673": 11, "#24a690": 12,
                         "#1f8da3": 13, "#156fa0": 14, "#34669a": 15]
            // The triangle's border moves; its inside and corners are locked.
            return .rows(rows, ranks: ranks, pop: .both, lockSize: CGSize(width: 8, height: 10),
                         locked: { row, index, count in
                             switch row {
                             case 0: return true
                             case rows.count - 1: return index == 0 || index == count - 1
                             default: return index != 0 && index != count - 1
                             }
                         },
                         cellSize: Level.tallCell(columns: 8))
        }
    }

    /// A block a fraction of the screen width wide and 20 points taller than it is wide.
    private static func tallCell(columns: CGFloat) -> (CGSize) -> CGSize {
        { screen in
            let width = (screen.width / columns).rounded()
            return CGSize(width: width, height: width + 20)
        }
    }
}
