import Foundation

import Surge
import StateSpace

public class ZeroMotionModel {
    public init() {
        // nothing
    }
}

extension ZeroMotionModel: Statable {
    public typealias State = Vector<Double>
}

extension ZeroMotionModel: UncontrollableMotionModelProtocol {
   public func apply(state x: State) -> State {
        return x
    }
}

extension ZeroMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        // This model cannot fail.
    }
}
