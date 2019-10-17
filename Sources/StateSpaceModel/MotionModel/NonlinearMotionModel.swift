import Foundation

import Surge

public class NonlinearMotionModel {
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
            rows: dimensions.state,
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

extension NonlinearMotionModel: StatefulModelProtocol {
    public typealias State = Vector<Double>
}

extension NonlinearMotionModel: DifferentiableModelProtocol {
    public typealias Jacobian = Matrix<Double>
}

extension NonlinearMotionModel: UncontrollableMotionModelProtocol {
    public func apply(state x: State) -> State {
        return self.function(x)
    }
}

extension NonlinearMotionModel: DifferentiableMotionModelProtocol {
    public func jacobian(state x: State) -> Jacobian {
        return self.jacobian(x)
    }
}

extension NonlinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        // To validate a function-defined model one needs to actually run it on some dummy data.
        // Given the obvious overhead of such a thorough check we choose to only run it on DEBUG builds:
        
        #if DEBUG
        let stateBefore = Vector(dimensions: dimensions.state, repeatedValue: 0.0)
        let stateAfter = self.apply(state: stateBefore)

        if stateAfter.dimensions != dimensions.state {
            throw VectorError.invalidDimensionCount(
                message: "Expected output vector of \(dimensions.state) dimensions, found \(stateAfter.dimensions)"
            )
        }
        #endif
    }
}
