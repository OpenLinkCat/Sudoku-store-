import Foundation

final class SudokuSolver {
    
    class func getBaseGridBasedOn(_ gameType:GameType) -> [Int] {
        switch gameType {
        case .classic:
            return [9,8,7,6,5,4,3,2,1,1,2,3,7,8,9,4,5,6,4,5,6,1,2,3,7,8,9,2,1,4,3,6,5,8,9,7,3,6,5,8,9,7,1,4,2,7,9,8,2,4,1,5,6,3,5,3,2,4,1,6,9,7,8,6,4,1,9,7,8,2,3,5,8,7,9,5,3,2,6,1,4]
        case .diagonal:
            return [9,8,7,6,5,4,3,2,1,1,2,3,7,8,9,4,5,6,4,5,6,1,2,3,7,8,9,2,1,4,3,6,8,5,9,7,3,6,5,9,4,7,8,1,2,7,9,8,2,1,5,6,3,4,5,4,9,8,7,2,1,6,3,8,3,1,4,9,6,2,7,5,6,7,2,5,3,1,9,4,8]
        case .twoDiagonals:
            return [9,8,7,6,5,4,3,2,1,1,2,3,7,8,9,4,5,6,4,5,6,1,2,3,7,8,9,2,1,4,8,6,5,9,3,7,3,6,5,9,4,7,2,1,8,7,9,8,2,3,1,5,6,4,6,7,9,5,1,2,8,4,3,5,3,1,4,7,8,6,9,2,8,4,2,3,9,6,1,7,5]
        case .romb:
            return [9,8,7,6,5,4,3,2,1,1,2,3,7,8,9,4,5,6,4,5,6,1,2,3,7,8,9,2,1,4,3,7,5,9,6,8,3,6,5,4,9,8,1,7,2,7,9,8,2,1,6,5,3,4,5,4,2,9,6,7,8,1,3,6,7,9,8,3,1,2,4,5,8,3,1,5,4,2,6,9,7]
        default:return [Int]()
        }
    }
    
}
