import Foundation

import Surge

public class LinearObservationModel {
    public let state: Matrix<Double>

    public init(
        state: Matrix<Double>
    ) {
        self.state = state
    }
}

extension LinearObservationModel: DimensionalModelProtocol {
    public var dimensions: DimensionsProtocol {
        // Given a square matrix it doesn't matter
        // whether to return `matrix.rows` or `matrix.columns`:
        return StateDimensions(state: self.state.rows)
    }
}

extension LinearObservationModel: StatefulModelProtocol {
    public typealias State = Vector<Double>
}

extension LinearObservationModel: ObservableModelProtocol {
    public typealias Observation = Vector<Double>
}

extension LinearObservationModel: ObservationModelProtocol {
   public func apply(state x: State) -> Observation {
        let a = self.state
        return a * x
    }
}

extension LinearObservationModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        typealias TypedDimensions = ObservableStateDimensionsProtocol

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

        guard self.state.rows == typedDimensions.observation else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(typedDimensions.state) columns in `self.state`, found \(self.state.rows)"
            )
        }
    }
}
