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
        typealias TypedDimensions = ObservedStateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard typedDimensions.state == typedDimensions.observation else {
            throw DimensionsError.invalidValue(
                message: "Expected `dimension.state == dimensions.observation, found `\(typedDimensions.state) != \(typedDimensions.observation)"
            )
        }
    }
}
