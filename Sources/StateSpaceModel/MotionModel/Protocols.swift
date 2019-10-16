import Foundation

import Surge

public protocol DimensionsValidatable {
    /// Validate the model for a given dimensional environment, or throw `Error`.
    ///
    /// - Parameters:
    ///   - dimensions: the environment's dimensions
    func validate(for dimensions: DimensionsProtocol) throws
}

//public protocol DimensionalModelProtocol {
//    associatedtype Dimensions: DimensionsProtocol
//
//    var dimensions: Dimensions { get }
//}

public protocol DimensionalModelProtocol {
    var dimensions: DimensionsProtocol { get }
}

public protocol StatefulModelProtocol {
    associatedtype State
}

public protocol ControllableModelProtocol {
    associatedtype Control
}

public protocol DifferentiableModel {
    associatedtype Jacobian
}

public protocol MotionModelProtocol: StatefulModelProtocol {
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

public protocol ControllableMotionModelProtocol: ControllableModelProtocol, StatefulModelProtocol {
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
    func apply(state x: State, control u: Control) -> State
}

public protocol DifferentiableMotionModel: StatefulModelProtocol, DifferentiableModel {
    /// Calculate jacobian matrix:
    ///
    /// ```
    /// F(k) = df(k)|
    ///        -----|
    ///         d(x)|
    ///             |x=X
    /// ```
    func jacobian(state x: State) -> Jacobian
}

public protocol ControllableDifferentiableMotionModelProtocol: ControllableModelProtocol, StatefulModelProtocol, DifferentiableModel {
    /// Calculate jacobian matrix:
    ///
    /// ```
    /// F(k) = df(k)|
    ///        -----|
    ///         d(x)|
    ///             |x=X
    /// ```
    func jacobian(state x: State, control u: Control) -> Jacobian
}
