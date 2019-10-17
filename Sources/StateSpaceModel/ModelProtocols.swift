import Foundation

public protocol StatefulModelProtocol {
    associatedtype State
}

public protocol ControllableModelProtocol {
    associatedtype Control
}

public protocol ObservableModelProtocol {
    associatedtype Observation
}

public protocol DifferentiableModelProtocol {
    associatedtype Jacobian
}

public protocol DimensionalModelProtocol {
    var dimensions: DimensionsProtocol { get }
}

public protocol DimensionsValidatable {
    /// Validate the model for a given dimensional environment, or throw `Error`.
    ///
    /// - Parameters:
    ///   - dimensions: the environment's dimensions
    func validate(for dimensions: DimensionsProtocol) throws
}
