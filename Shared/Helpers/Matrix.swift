//
//  Matrix.swift
//  Shared (Helper)
//
//  Created by Tanner on 10/26/21.
//  https://stackoverflow.com/a/53421491/8915983
//


/// A generic data structure for managing a 2-dimensional matrix.
struct Matrix<T> {
    
    
    // MARK: Properties
    
    /// The number of rows in the matrix (matrix 1st dimension)
    let rows: Int
    
    /// The number of columns in the matrix (matrix 2nd dimension)
    let columns: Int
    
    /// A flat 1-dimensional array that contains the data and represents the 2-dimensional data structure
    var grid: [T]
    
    
    // MARK: Initializers
    
    /**
     Initializes a matrix with default values.
     
     - Parameters:
        - rows: Number of rows in the matrix (matrix 1st dimension)
        - columns: Number of columns in the matrix (matrix 2nd dimension)
        - defaultValue: The value with which to populate the entire matrix
     */
    init(rows: Int, columns: Int, defaultValue: T) {
        assert({ rows > 0 && columns > 0 }(), "More than one row and more than one column are required")
        
        self.rows = rows
        self.columns = columns
        self.grid = Array(repeating: defaultValue, count: rows * columns)
    }
    
    /**
     Initializes a matrix with `0` as the default value.
     
     - Parameters:
        - rows: Number of rows in the matrix (matrix 1st dimension)
        - columns: Number of columns in the matrix (matrix 2nd dimension)
     */
    init(rows: Int, columns: Int) where T == Int {
        self.init(rows: rows, columns: columns, defaultValue: 0)
    }
    
    /**
     Initializes a matrix with `false` as the default value.
     
     - Parameters:
        - rows: Number of rows in the matrix (matrix 1st dimension)
        - columns: Number of columns in the matrix (matrix 2nd dimension)
     */
    init(rows: Int, columns: Int) where T == Bool {
        self.init(rows: rows, columns: columns, defaultValue: false)
    }
    
    
    // MARK: Subscripts
    
    /// A subscript for accessing and mutating one element in the matrix.
    subscript(row: Int, column: Int) -> T {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return self.grid[(row * self.columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            self.grid[(row * self.columns) + column] = newValue
        }
    }
    
    /// A read-only subscript for accessing one row in the matrix.
    subscript(row: Int) -> [T] {
        assert(rowIndexIsValid(row), "Row index out of range")
        var array: [T] = []
        for column in 0..<self.columns {
            array.append(self[row, column])
        }
        return array
    }

    
    // MARK: Public Object Methods

    /**
     Sums up all elements in the matrix.

     - Returns: The sum of all matrix elements.
     */
    func sum() -> Int where T == Int {
        var sum = 0
        for i in 0..<self.grid.count {
            sum += self.grid[i]
        }
        return sum
    }
    
    /**
     Sums up all elements in the specified matrix row.
     
     - Parameters:
        - row: The row whose columns shall be summed
     
     - Returns: The sum of all elements in the matrix row.
     */
    func sumColumns(at row: Int) -> Int where T == Int {
        var sum = 0
        assert(rowIndexIsValid(row), "Row index out of range")
        
        for j in 0..<self.columns {
            sum += self.grid[(row * self.columns) + j]
        }
        
        return sum
    }
    
    /**
     Identifies the matrix row whose sum of elements is minimum.
     
     - Parameters:
        - rowExceptions: An array of row indices, whose elements have already been summed
     
     - Returns: The row index in the matrix whose sum of elements is minimum.
     */
    func rowWithMinSum(rowExceptions: [Int]) -> Int where T == Int {
        var minSum: Int?
        var rowWithMin: Int?
        
        // sort exceptions in descending order to create a stack
        var rowExceptionsSorted = rowExceptions.sorted(by: { $0 > $1 })
        var rowException: Int? = rowExceptionsSorted.popLast()
        
        for row in 0..<self.rows {
            // go to next iteration in loop if row is an exception
            if row == rowException {
                // pop next exception off the stack
                rowException = rowExceptionsSorted.popLast()
                continue
            }
            
            // find minimum sum
            let sum = sumColumns(at: row)
            
            // check for smaller sum
            if minSum != nil {
                // force unwrap since we know var is not nil
                if sum < minSum! {
                    minSum = sum
                    rowWithMin = row
                }
            }
            // init vars if they haven't been already
            else {
                minSum = sum
                rowWithMin = row
            }
        }
        
        // return the row that contains the minimum sum
        return rowWithMin!
    }
    
    
    // MARK: Private Object Methods
    
    /**
     Determines if the matrix index is valid (within range).
     
     - Parameters:
        - row: The row index
        - column: The column index
     
     - Returns: `true` if both indices are within range, `false` otherwise.
     */
    private func indexIsValid(row: Int, column: Int) -> Bool {
        return rowIndexIsValid(row) && columnIndexIsValid(column)
    }
    
    /**
     Determines if the row index is valid (within range).
     
     - Parameters:
        - row: The row index
     
     - Returns: `true` if the index is within range, `false` otherwise.
     */
    private func rowIndexIsValid(_ row: Int) -> Bool {
        return row >= 0 && row < self.rows
    }
    
    /**
     Determines if the column index is valid (within range).
     
     - Parameters:
        - column: The column index
     
     - Returns: `true` if the index is within range, `false` otherwise.
     */
    private func columnIndexIsValid(_ column: Int) -> Bool {
        return column >= 0 && column < self.columns
    }
    
}
