import Foundation

class SudokuGenerator: Sudoku {
    
    var difficult: Difficult = .easy
    var gameType: GameType = .classic
    var id = 0
    
    private var gameCompleted: Bool { digits.filter { $0 == 0 }.isEmpty } //all cells solved
    
    var completion: (() -> () )?
    
    weak var delegate: SudokuDelegate?
    
    private(set) var digitsCount = [Int:Int]()
    private(set) var mistakes = 0
    private(set) var mistakesMade = [Int?]()
    private(set) var hintsMade = 0
    private(set) var hints = 0
    private(set) var gameLost = false
    
    init(difficult:Int,gameType:GameType,id:Int, delegate: SudokuDelegate? = nil,completion:(() -> ())? = nil  ) {
        super.init()
        self.delegate = delegate
        self.gameType = gameType
        self.completion = completion
        self.id = id
        mistakes = 3
        gameLost = false
        hints = 2
        switch difficult {
        case 0: self.difficult = .easy
        case 1: self.difficult = .medium
        case 2: self.difficult = .hard
        case 3: self.difficult = .expert
        default:break
        }
        clear()
        generate()
   }
   
    func cellTouchedAt(index:Int, digit:Int,shouldCountMistakes:Bool) {
        digits[index] = digit
        digitsCount[digit] = digitsCount[digit]! + 1
        if digits[index] != answers[index] { //mistake
            mistakesMade.append(index)
            if mistakesMade.count >= mistakes { //game lost
                if delegate == nil { fatalError("delegate can't be nil")}
                gameLost = true
                if shouldCountMistakes { delegate?.gameLost() }
            }
            
        }
        checkIfSomethingFilledAt(index)
        if gameCompleted {
            if delegate == nil { fatalError("delegate can't be nil")}
            delegate?.gameWon()
        }
   }
   
    func eraseAt(_ index:Int, _ digit:Int) {
        digits[index] = 0
        mistakesMade[mistakesMade.firstIndex(of: index)!] = nil
        digitsCount[digit] = digitsCount[digit]! - 1
   }
   
    func highlightButtons(_ index:Int) -> Set<Int> {
        var indexes = Set<Int>()
        let coordinates = self[index]
        let rowOffset = coordinates.column - coordinates.column%3
        let columnOffset = coordinates.row - coordinates.row%3
        for i in 0..<dimension {
            indexes.insert(dimension*coordinates.row + i )
            indexes.insert(coordinates.column + dimension*i )
            if gameType != .shape {
                indexes.insert(columnOffset*dimension + rowOffset + i/3*dimension + i%3)
            }
        }
        if gameType != .shape {
            indexes.formUnion(Indexes.getIndexesBasedOn(gameType, index: index).first)
            indexes.formUnion(Indexes.getIndexesBasedOn(gameType, index: index).second)
        } else {
            indexes.formUnion(ShapeSudoku.returnRightIndexesBasedOn(index, id: id))
        }
        
        return indexes
    }

    func highlightAllButtonsBasedOn(digit:Int) -> (active:Set<Int>,related:Set<Int>) {
        var output = (active:Set<Int>(),related:Set<Int>())
        for index in digits.indices {
            if digit == digits[index] {
                let coordinate = self[index]
                output.active.insert(index)
            output.related.formUnion(highlightButtons(coordinate.row*dimension+coordinate.column))
                if gameType != .shape {
                output.related.formUnion(Indexes.getIndexesBasedOn(gameType, index: index).first)
                output.related.formUnion(Indexes.getIndexesBasedOn(gameType, index: index).second)
                } else {
                output.related.formUnion(ShapeSudoku.returnRightIndexesBasedOn(index, id: id))
                }
            }
        }
        for i in digits.indices {
            if digits[i] != 0 { output.related.insert(i)}
        }
        return output
    }
    
    func canHint(index:Int) -> Bool {
        if hintsMade < hints  {
            if digits[index] == 0 {
                digits[index] = answers[index]
                checkIfSomethingFilledAt(index)
                digitsCount[digits[index]] = digitsCount[digits[index]]! + 1
                hintsMade += 1
                if gameCompleted { delegate?.gameWon()}
            }
            return true
        } else {
            delegate?.hintsLimitUsed()
            return false
        }
    }


    func generate() {
        if gameType == .shape {
            digits = ShapeSudokuSolver.getBaseGridBasedOn(id)
        } else {
            digits = SudokuSolver.getBaseGridBasedOn(gameType)
        }
        replaceDigits()
        removeDigits()
        calculateDigits()
        completion?()
    }
    

    private func replaceDigits() {
        let newDigits = [1,2,3,4,5,6,7,8,9].shuffled()
        for index in digits.indices {
            digits[index] = newDigits[digits[index]-1]
        }
        answers = digits
    }
        
    private func removeDigits() {
        var indexesToDelete = Set<Int>()
        while indexesToDelete.count <= difficult.rawValue {
            indexesToDelete.insert(Int.random(in: 0...80))
        }
        indexesToDelete.forEach { digits[$0] = 0 }
    }
    
    
    private func calculateDigits() {
        for i in 1...9 {
            digitsCount[i] = 0
        }
        for index in digits.indices {
            if digits[index] != 0 {
                digitsCount[digits[index]] = digitsCount[digits[index]]! + 1
            }
        }
    }
    
    func clear() {
        digits.removeAll()
        answers.removeAll()
        digitsCount.removeAll()
        mistakesMade.removeAll()
    }
    
    // MARK: - Delegation
    
    private func checkIfSomethingFilledAt(_ index:Int) {
        checkIfRowFilledAt(index)
        checkIfColumnFilledAt(index)
        checkIfBlockFilledAt(index)
        checkIfDiagonalFilledAt(index)
    }
    
    
    private func checkIfRowFilledAt(_ index:Int) {
        let indexes = Indexes.lineIndexesAt(index).filter { digits[$0] != 0 }
        if indexes.count == 9 { delegate?.animateRowWith(indexes) }
    }
    
    private func checkIfColumnFilledAt(_ index:Int) {
        let indexes = Indexes.columnIndexesAt(index).filter { digits[$0] != 0 }
        if indexes.count == 9 { delegate?.animateLineWith(indexes) }
    }
    
    private func checkIfBlockFilledAt(_ index:Int) {
        let indexes = Indexes.blockIndexesAt(index, gameType: gameType,id:id).filter { digits[$0] != 0 }
        if indexes.count == 9 { delegate?.animateBlockWith(indexes) }
    }
    
    private func checkIfDiagonalFilledAt(_ index:Int) {
        let firstIndexes = Indexes.getIndexesBasedOn(gameType, index: index).first
        let secondIndexes = Indexes.getIndexesBasedOn(gameType, index: index).second
        if firstIndexes.filter({ digits[$0] != 0 }).count == (gameType == .twoDiagonals ? 8 : 9) {
            delegate?.animateRowWith(firstIndexes)
        }
        if secondIndexes.filter({ digits[$0] != 0 }).count == (gameType == .twoDiagonals ? 8 : 9) {
            delegate?.animateRowWith(secondIndexes)
        }
    }
    
    // persistence
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hints = try container.decode(Int.self, forKey: .hints)
        hintsMade = try container.decode(Int.self, forKey: .hintsMade)
        mistakes = try container.decode(Int.self, forKey: .mistakes)
        mistakesMade = try container.decode([Int?].self, forKey: .mistakesMade)
        difficult = try container.decode(Difficult.self, forKey: .difficult)
        digits = try container.decode([Int].self, forKey: .digits)
        answers = try container.decode([Int].self, forKey: .answers)
        digitsCount = try container.decode([Int:Int].self, forKey: .digitsCount)
        gameType = try container.decode(GameType.self, forKey: .gameType)
        id = try container.decode(Int.self, forKey: .id)
        gameLost = try container.decode(Bool.self, forKey: .gameLost)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hints, forKey: .hints)
        try container.encode(hintsMade, forKey: .hintsMade)
        try container.encode(mistakes, forKey: .mistakes)
        try container.encode(mistakesMade, forKey: .mistakesMade)
        try container.encode(difficult, forKey: .difficult)
        try container.encode(digits, forKey: .digits)
        try container.encode(answers, forKey: .answers)
        try container.encode(digitsCount, forKey: .digitsCount)
        try container.encode(gameType, forKey: .gameType)
        try container.encode(id, forKey: .id)
        try container.encode(gameLost, forKey: .gameLost)
    }
    
    private enum CodingKeys:String,CodingKey {
        case hints = "hints"
        case hintsMade = "hintsMade"
        case mistakes = "mistakes"
        case mistakesMade = "mistakesMade"
        case difficult = "difficult"
        case digits = "digits"
        case gameLost = "gameLost"
        case answers = "answers"
        case digitsCount = "digitsCount"
        case gameType = "gameType"
        case id = "id"
    }
   
}
