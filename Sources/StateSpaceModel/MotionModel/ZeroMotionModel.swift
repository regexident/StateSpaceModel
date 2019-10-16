import Foundation

import Surge

public class ZeroMotionModel {
    public init() {
        // nothing
    }
}

extension ZeroMotionModel: StatefulModelProtocol {
    public typealias State = Vector<Double>
}

extension ZeroMotionModel: MotionModelProtocol {
   public func apply(state x: State) -> State {
        return x
    }
}

extension ZeroMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        // This model cannot fail.
    }
}
