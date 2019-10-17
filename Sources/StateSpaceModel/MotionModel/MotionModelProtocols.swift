import Foundation

import Surge

public protocol MotionModelProtocol: StatefulModelProtocol {

}

public protocol UncontrollableMotionModelProtocol: MotionModelProtocol {
    /// Calculate predicted state estimate
    ///
    /// Linear case:
    /// ```
    /// x'(k) = A * x(k-1) + B * u(k)
    /// ```
    ///
    /// Non-linear case:
    /// ```
    /// x'(k) = f(x(k-1))
    /// ```
    func apply(state x: State) -> State
}

public protocol ControllableMotionModelProtocol: MotionModelProtocol, ControllableModelProtocol {
    /// Calculate predicted state estimate
    ///
    /// Linear case:
    /// ```
    /// x'(k) = A * x(k-1) + B * u(k)
    /// ```
    ///
    /// Non-linear case:
    /// ```
    /// x'(k) = f(x(k-1))
    /// ```
    func apply(state x: State, control u: Control) -> State
}

public protocol DifferentiableMotionModelProtocol: StatefulModelProtocol, DifferentiableModelProtocol {
    /// Calculate jacobian matrix:
    ///
    /// Linear case:
    /// ```
    /// F(k) = A
    /// ```
    ///
    /// Non-linear case:
    /// ```
    /// F(k) = df(k)|
    ///        -----|
    ///         d(x)|
    ///             |x=X
    /// ```
    func jacobian(state x: State) -> Jacobian
}

public protocol ControllableDifferentiableMotionModelProtocol: ControllableModelProtocol, StatefulModelProtocol, DifferentiableModelProtocol {
    /// Calculate jacobian matrix:
    ///
    /// Linear case:
    /// ```
    /// F(k) = A
    /// ```
    /// 
    /// Non-linear case:
    /// ```
    /// F(k) = df(k)|
    ///        -----|
    ///         d(x)|
    ///             |x=X
    /// ```
    func jacobian(state x: State, control u: Control) -> Jacobian
}
