import Foundation

import Surge
import StateSpace

public protocol ControlModelProtocol: Statable, Controllable {
    /// Calculate state change from control
    ///
    /// Linear case:
    /// ```
    /// x'(k) = B * u(k)
    /// ```
    func apply(control u: Control) -> State
}
