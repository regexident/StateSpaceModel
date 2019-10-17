import Foundation

import Surge

public class ControllableNonlinearMotionModel {
    public typealias StateFunction = (State, Control) -> State
    public typealias JacobianFunction = (State, Control) -> Jacobian

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
        self.init(function: function) { state, control in
            return jacobian.numeric(state: state) { function($0, control) }
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

extension ControllableNonlinearMotionModel: StatefulModelProtocol {
    public typealias State = LinearMotionModel.State
}

extension ControllableNonlinearMotionModel: ControllableModelProtocol {
    public typealias Control = Vector<Double>
}

extension ControllableNonlinearMotionModel: DifferentiableModelProtocol {
    public typealias Jacobian = Matrix<Double>
}

extension ControllableNonlinearMotionModel: ControllableMotionModelProtocol {
    public func apply(state x: State, control u: Control) -> State {
        return self.function(x, u)
    }
}

extension ControllableNonlinearMotionModel: ControllableDifferentiableMotionModelProtocol {
    public func jacobian(state x: State, control u: Control) -> Jacobian {
        return self.jacobian(x, u)
    }
}

extension ControllableNonlinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        // To validate a function-defined model one needs to actually run it on some dummy data.
        // Given the obvious overhead of such a thorough check we choose to only run it on DEBUG builds:

        #if DEBUG
        let control = Vector(dimensions: dimensions.control, repeatedValue: 0.0)
        let stateBefore = Vector(dimensions: dimensions.state, repeatedValue: 0.0)
        let stateAfter = self.apply(state: stateBefore, control: control)

        if stateAfter.dimensions != dimensions.state {
            throw VectorError.invalidDimensionCount(
                message: "Expected output vector of \(dimensions.state) dimensions, found \(stateAfter.dimensions)"
            )
        }
        #endif
    }
}
