import Foundation

import Surge

public protocol ObservationModelProtocol: StatefulModelProtocol, ObservableModelProtocol {
    /// Calculate observation estimate
    ///
    /// ```
    /// z'(k) = H * x'(k)
    /// ```
    func apply(state x: State) -> Observation
}

public protocol DifferentiableObservationModel: StatefulModelProtocol, DifferentiableModel {
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
