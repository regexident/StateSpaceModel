import Foundation

import Surge
import StateSpace

public class NonlinearObservationModel {
    public typealias StateFunction = (State) -> State
    public typealias JacobianFunction = (State) -> Jacobian

    public typealias Functions = (state: StateFunction, jacobian: JacobianFunction)

    private let function: StateFunction
    private let jacobian: JacobianFunction

    public convenience init(
        dimensions: DimensionsProtocol,
        function: @escaping StateFunction
    ) {
        let jacobian = NumericJacobian(
            rows: dimensions.observation,
            columns: dimensions.state
        )
        self.init(function: function) { state in
            return jacobian.numeric(state: state) { function($0) }
        }
    }

    public init(
        function: @escaping StateFunction,
        jacobian: @escaping JacobianFunction
    ) {
        self.function = function
        self.jacobian = jacobian
    }
}

extension NonlinearObservationModel: Statable {
    public typealias State = Vector<Double>
}

extension NonlinearObservationModel: Observable {
    public typealias Observation = Vector<Double>
}

extension NonlinearObservationModel: Differentiable {
    public typealias Jacobian = Matrix<Double>
}

extension NonlinearObservationModel: ObservationModelProtocol {
    public func apply(state x: State) -> Observation {
        return self.function(x)
    }
}

extension NonlinearObservationModel: DifferentiableObservationModelProtocol {
    public func jacobian(state x: State) -> Jacobian {
        return self.jacobian(x)
    }
}

extension NonlinearObservationModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        // To validate a function-defined model one needs to actually run it on some dummy data.
        // Given the obvious overhead of such a thorough check we choose to only run it on DEBUG builds:
        
        #if DEBUG
        let state = Vector(dimensions: dimensions.state, repeatedValue: 0.0)
        let observation = self.apply(state: state)

        if observation.dimensions != dimensions.observation {
            throw VectorError.invalidDimensionCount(
                message: "Expected output vector of \(dimensions.observation) dimensions, found \(observation.dimensions)"
            )
        }
        #endif
    }
}
