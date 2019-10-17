import Foundation

import Surge

public class TransparentObservationModel {
    public init() {
        // nothing
    }
}

extension TransparentObservationModel: StatefulModelProtocol {
    public typealias State = Vector<Double>
}

extension TransparentObservationModel: ObservableModelProtocol {
    public typealias Observation = Vector<Double>
}

extension TransparentObservationModel: ObservationModelProtocol {
   public func apply(state x: State) -> Observation {
        return x
    }
}

extension TransparentObservationModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        guard dimensions.state == dimensions.observation else {
            throw DimensionsError.invalidValue(
                message: "Expected `dimension.state == dimensions.observation, found `\(dimensions.state) != \(dimensions.observation)"
            )
        }
    }
}
