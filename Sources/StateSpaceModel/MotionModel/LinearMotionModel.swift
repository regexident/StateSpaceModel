import Foundation

import Surge
import StateSpace

public class LinearMotionModel {
    public let state: Matrix<Double>

    public init(
        state: Matrix<Double>
    ) {
        assert(state.shape == .square, "Expected square matrix")
        self.state = state
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
        let a = self.state
        return a * x
    }
}

extension LinearMotionModel: DifferentiableMotionModelProtocol {
    public func jacobian(state x: State) -> Jacobian {
        return self.state
    }
}

extension LinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        guard self.state.columns == dimensions.state else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(dimensions.state) columns in `self.state`, found \(self.state.columns)"
            )
        }

        guard self.state.rows == dimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(dimensions.state) columns in `self.state`, found \(self.state.rows)"
            )
        }
    }
}
