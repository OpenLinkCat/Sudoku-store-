import Foundation

class DiagonalSudokuSolver: SudokuSolver {
 
    private(set) var leftDiagonal = Set(arrayLiteral: 9)
    private(set) var rightDiagonal = Set(arrayLiteral: 1)

    
    override func updateData(insert: Bool, _ row: Int, _ column: Int, _ num: Int) {
        if insert {
            if row == column { leftDiagonal.insert(num) }
            if row + column == 8 { rightDiagonal.insert(num)}
        } else {
            if row == column { leftDiagonal.remove(num)}
            if row + column == 8 { rightDiagonal.remove(num)}
        }
        print("row = \(row) column = \(column)")
        print(leftDiagonal)
        super.updateData(insert: insert, row, column, num)
    }
    
    override func isSaveAt(_ i: Int, _ j: Int, _ digit: Int) -> Bool {
//        print(leftDiagonal)
        if i == j { return !leftDiagonal.contains(digit) }
        if i + j == 8 { return !rightDiagonal.contains(digit) }
        return super.isSaveAt(i, j, digit)
    }


    
}
