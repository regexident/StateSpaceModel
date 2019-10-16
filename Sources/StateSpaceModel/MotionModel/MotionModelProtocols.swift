import Foundation

import Surge

public protocol MotionModelProtocol: StatefulModelProtocol {

}

public protocol UncontrollableMotionModelProtocol: MotionModelProtocol {
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

public protocol ControllableMotionModelProtocol: MotionModelProtocol, ControllableModelProtocol {
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
