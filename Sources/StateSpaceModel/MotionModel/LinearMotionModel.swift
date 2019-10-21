import Foundation

import Surge
import StateSpace

public class LinearMotionModel {
    public let a: Matrix<Double>

    public init(
        a: Matrix<Double>
    ) {
        assert(a.shape == .square, "Expected square matrix")
        self.a = a
    }
}

extension LinearMotionModel: Statable {
    public typealias State = Vector<Double>
}

extension LinearMotionModel: Differentiable {
    public typealias Jacobian = Matrix<Double>
}

extension LinearMotionModel: UncontrollableMotionModelProtocol {
   public func apply(state x: State) -> State {
        return self.a * x
    }
}

extension LinearMotionModel: DifferentiableMotionModelProtocol {
    public func jacobian(state x: State) -> Jacobian {
        return self.a
    }
}

extension LinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        guard self.a.columns == dimensions.state else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(dimensions.state) columns in `self.a`, found \(self.a.columns)"
            )
        }

        guard self.a.rows == dimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(dimensions.state) columns in `self.a`, found \(self.a.rows)"
            )
        }
    }
}
