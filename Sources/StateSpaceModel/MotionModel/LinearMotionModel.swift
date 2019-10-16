import Foundation

import Surge

public class LinearMotionModel {
    public let state: Matrix<Double>

    public init(
        state: Matrix<Double>
    ) {
        assert(state.shape == .square, "Expected square matrix")
        self.state = state
    }
}

extension LinearMotionModel: DimensionalModelProtocol {
    public var dimensions: DimensionsProtocol {
        // Given a square matrix it doesn't matter
        // whether to return `matrix.rows` or `matrix.columns`:
        return StateDimensions(state: self.state.rows)
    }
}

extension LinearMotionModel: StatefulModelProtocol {
    public typealias State = Vector<Double>
}

extension LinearMotionModel: UncontrollableMotionModelProtocol {
   public func apply(state x: State) -> State {
        let a = self.state
        return a * x
    }
}

extension LinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        typealias TypedDimensions = StateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard self.state.columns == typedDimensions.state else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(typedDimensions.state) columns in `self.state`, found \(self.state.columns)"
            )
        }

        guard self.state.rows == typedDimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(typedDimensions.state) columns in `self.state`, found \(self.state.rows)"
            )
        }
    }
}
