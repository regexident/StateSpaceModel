import Foundation

import Surge

public class ControllableNonlinearMotionModel {
    public typealias StateFunction = (State, Control) -> State
    public typealias JacobianFunction = (State, Control) -> Jacobian

    public typealias Functions = (state: StateFunction, jacobian: JacobianFunction)

    private let function: StateFunction
    private let jacobian: JacobianFunction

    public init(
        dimensions: ControlledStateDimensionsProtocol,
        function: @escaping StateFunction,
        jacobian: JacobianFunction? = nil
    ) {
        self.function = function
        self.jacobian = jacobian ?? Self.numericJacobian(for: function, dimensions: dimensions)
    }

    private static func numericJacobian(
        for function: @escaping StateFunction,
        dimensions: ControlledStateDimensionsProtocol
    ) -> JacobianFunction {
        return { state, control in
            let jacobian = NumericJacobian(rows: dimensions.state, columns: dimensions.state)
            return jacobian.numeric(state: state) { function($0, control) }
        }
    }
}

extension ControllableNonlinearMotionModel: StatefulModelProtocol {
    public typealias State = LinearMotionModel.State
}

extension ControllableNonlinearMotionModel: ControllableModelProtocol {
    public typealias Control = Vector<Double>
}

extension ControllableNonlinearMotionModel: DifferentiableModel {
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
        typealias TypedDimensions = ControlledStateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        // To validate a function-defined model one needs to actually run it on some dummy data.
        // Given the obvious overhead of such a thorough check we choose to only run it on DEBUG builds:

        #if DEBUG
        let control = Vector(dimensions: typedDimensions.control, repeatedValue: 0.0)
        let stateBefore = Vector(dimensions: typedDimensions.state, repeatedValue: 0.0)
        let stateAfter = self.apply(state: stateBefore, control: control)

        if stateAfter.dimensions != typedDimensions.state {
            throw VectorError.invalidDimensionCount(
                message: "Expected output vector of \(typedDimensions.state) dimensions, found \(stateAfter.dimensions)"
            )
        }
        #endif
    }
}
