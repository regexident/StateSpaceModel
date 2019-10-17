import Foundation

public protocol DimensionsValidatable {
    /// Validate the model for a given dimensional environment, or throw `Error`.
    ///
    /// - Parameters:
    ///   - dimensions: the environment's dimensions
    func validate(for dimensions: DimensionsProtocol) throws
}
