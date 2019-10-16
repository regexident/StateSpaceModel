import Foundation

import Surge

public class ZeroMotionModel {
    private let nominalDimensions: StateDimensions

    public init(
        dimensions: StateDimensionsProtocol
    ) {
        self.nominalDimensions = StateDimensions(state: dimensions.state)
    }
}

extension ZeroMotionModel: DimensionalModelProtocol {
    public var dimensions: DimensionsProtocol {
        return self.nominalDimensions
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
        typealias TypedDimensions = StateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard self.nominalDimensions.state == typedDimensions.state else {
            throw DimensionsError.invalidValue(
                message: "Expected dimensions of \(typedDimensions.state) in `self.dimensions`, found \(self.nominalDimensions.state)"
            )
        }
    }
}
