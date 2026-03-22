import Foundation

final class RuleUtil {
    private static let prizeFactor1th = 200
    private static let prizeFactor2th = 100
    private static let prizeFactor3th = 50
    private static let prizeFactor4th = 30
    private static let prizeFactor5th = 20
    private static let prizeFactor6th = 15
    private static let prizeFactor7th = 13
    private static let prizeFactor8th = 11
    private static let prizeFactor9th = 10
    private static let prizeFactor10th = 8
    private static let prizeFactor11th = 5
    private static let prizeFactor12th = 2
    private static let prizeFactor13th = 1

    private static let ratPosition = 14
    private static let oxPosition = 0
    private static let tigerPosition = 1
    private static let rabbitPosition = 2
    private static let dragonPosition = 3
    private static let snakePosition = 4
    private static let horsePosition = 5
    private static let goatPosition = 6
    private static let monkeyPosition = 7
    private static let roosterPosition = 8
    private static let dogPosition = 9
    private static let pigPosition = 10
    private static let ratPosition2 = 11
    private static let oxPosition2 = 12
    private static let tigerPosition2 = 13

    static func getPrizeFactorBy3Connect(_ winPosition: Int, money currentMoneyLevel: Int) -> Int {
        let prizeFactor = getPrizeFactorBy3Connect(winPosition)
        return prizeFactor * currentMoneyLevel
    }

    static func getPrizeFactorBy3Connect(_ winPosition: Int) -> Int {
        switch winPosition {
        case ratPosition, ratPosition2:
            return prizeFactor12th
        case oxPosition, oxPosition2:
            return prizeFactor5th
        case tigerPosition, tigerPosition2:
            return prizeFactor3th
        case rabbitPosition:
            return prizeFactor9th
        case dragonPosition:
            return prizeFactor2th
        case snakePosition:
            return prizeFactor4th
        case horsePosition:
            return prizeFactor10th
        case goatPosition:
            return prizeFactor1th
        case monkeyPosition:
            return prizeFactor11th
        case roosterPosition:
            return prizeFactor6th
        case dogPosition:
            return prizeFactor7th
        case pigPosition:
            return prizeFactor8th
        default:
            return 0
        }
    }

    static func getPrizeFactorBy2Connect(_ currentMoneyLevel: Int) -> Int {
        return getPrizeFactorBy2Connect() * currentMoneyLevel
    }

    static func getPrizeFactorBy2Connect() -> Int {
        return prizeFactor13th
    }

    static func isBigWin(_ winPosition: Int) -> Bool {
        return winPosition == goatPosition
    }
}
