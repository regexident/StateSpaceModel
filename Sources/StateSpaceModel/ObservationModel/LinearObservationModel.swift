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
        guard self.state.columns == dimensions.state else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(dimensions.state) columns in `self.state`, found \(self.state.columns)"
            )
        }

        guard self.state.rows == dimensions.observation else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(dimensions.state) columns in `self.state`, found \(self.state.rows)"
            )
        }
    }
}
