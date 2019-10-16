import Foundation

import Surge

public class NonlinearObservationModel {
    public typealias StateFunction = (State) -> State
    public typealias JacobianFunction = (State) -> Jacobian

    public typealias Functions = (state: StateFunction, jacobian: JacobianFunction)

    private let function: StateFunction
    private let jacobian: JacobianFunction

    public init(
        dimensions: StateDimensionsProtocol,
        function: @escaping StateFunction,
        jacobian: JacobianFunction? = nil
    ) {
        self.function = function
        self.jacobian = jacobian ?? Self.numericJacobian(for: function, dimensions: dimensions)
    }

    private static func numericJacobian(
        for function: @escaping StateFunction,
        dimensions: StateDimensionsProtocol
    ) -> JacobianFunction {
        return { state in
            let jacobian = NumericJacobian(rows: dimensions.state, columns: dimensions.state)
            return jacobian.numeric(state: state) { function($0) }
        }
    }
}

extension NonlinearObservationModel: StatefulModelProtocol {
    public typealias State = Vector<Double>
}

extension NonlinearObservationModel: ObservableModelProtocol {
    public typealias Observation = Vector<Double>
}

extension NonlinearObservationModel: DifferentiableModel {
    public typealias Jacobian = Matrix<Double>
}

extension NonlinearObservationModel: ObservationModelProtocol {
    public func apply(state x: State) -> Observation {
        return self.function(x)
    }
}

extension NonlinearObservationModel: DifferentiableObservationModel {
    public func jacobian(state x: State) -> Jacobian {
        return self.jacobian(x)
    }
}

extension NonlinearObservationModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        typealias TypedDimensions = ObservedStateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        // To validate a function-defined model one needs to actually run it on some dummy data.
        // Given the obvious overhead of such a thorough check we choose to only run it on DEBUG builds:
        
        #if DEBUG
        let state = Vector(dimensions: typedDimensions.state, repeatedValue: 0.0)
        let observation = self.apply(state: state)

        if observation.dimensions != typedDimensions.observation {
            throw VectorError.invalidDimensionCount(
                message: "Expected output vector of \(typedDimensions.observation) dimensions, found \(observation.dimensions)"
            )
        }
        #endif
    }
}
