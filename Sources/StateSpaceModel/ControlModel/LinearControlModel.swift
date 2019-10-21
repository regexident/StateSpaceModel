import Foundation

import Surge
import StateSpace

public class LinearControlModel {
    public let b: Matrix<Double>

    public init(
        b: Matrix<Double>
    ) {
        self.b = b
    }
}

extension LinearControlModel: Statable {
    public typealias State = Vector<Double>
}

extension LinearControlModel: Controllable {
    public typealias Control = Vector<Double>
}

extension LinearControlModel: ControlModelProtocol {
   public func apply(control u: Control) -> State {
        return self.b * u
    }
}

extension LinearControlModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        guard self.b.columns == dimensions.state else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(dimensions.state) columns in `self.b`, found \(self.b.columns)"
            )
        }

        guard self.b.rows == dimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(dimensions.state) columns in `self.b`, found \(self.b.rows)"
            )
        }
    }
}
