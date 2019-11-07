import Foundation

public enum DimensionsError: Swift.Error {
    case invalidType(message: String)
    case invalidValue(message: String)
}

public enum VectorError: Swift.Error {
    case invalidDimensionCount(message: String)
}

public enum MatrixError: Swift.Error {
    case invalidColumnCount(message: String)
    case invalidRowCount(message: String)
}
