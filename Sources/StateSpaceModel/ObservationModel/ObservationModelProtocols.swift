import Foundation

import Surge
import StateSpace

public protocol ObservationModelProtocol: Statable, Observable {
    /// Calculate observation estimate
    ///
    /// ```
    /// z'(k) = H * x'(k)
    /// ```
    func apply(state x: State) -> Observation
}

public protocol DifferentiableObservationModelProtocol: Statable, Differentiable {
    /// Calculate jacobian matrix:
    ///
    /// ```
    /// H(k) = dh(k)|
    ///        -----|
    ///         d(x)|
    ///             |x=X
    /// ```
    func jacobian(state x: State) -> Jacobian
}
