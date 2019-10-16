import Foundation

import Surge

public protocol DimensionsValidatable {
    /// Validate the model for a given dimensional environment, or throw `Error`.
    ///
    /// - Parameters:
    ///   - dimensions: the environment's dimensions
    func validate(for dimensions: DimensionsProtocol) throws
}

public protocol MotionModelProtocol {
    associatedtype State
    associatedtype Dimensions: StateDimensionsProtocol

    var dimensions: Dimensions { get }

    /// Calculate predicted state estimate
    ///
    /// ```
    /// x'(k) = A * x(k-1) + B * u(k)
    /// ```
    ///
    /// or more generally
    ///
    /// ```
    /// x'(k) = f(x(k-1))
    /// ```
    func apply(state x: State) -> State
}

public protocol ControllableMotionModelProtocol: MotionModelProtocol
    where Dimensions: ControlDimensionsProtocol
{
    associatedtype Control

    /// Calculate predicted state estimate
    ///
    /// ```
    /// x'(k) = A * x(k-1) + B * u(k)
    /// ```
    ///
    /// or more generally
    ///
    /// ```
    /// x'(k) = f(x(k-1))
    /// ```
    func apply(state x: State, control u: Control?) -> State
}
