import Foundation

import Surge

public class NonlinearMotionModel {
    public let dimensions: Dimensions

    public typealias StateFunction = (Vector<Double>) -> Vector<Double>
    public typealias JacobianFunction = (Vector<Double>) -> Matrix<Double>

    public typealias Functions = (state: StateFunction, jacobian: JacobianFunction)

    private let function: StateFunction
    private let jacobian: JacobianFunction

    public convenience init(
        dimensions: StateDimensionsProtocol,
        function: @escaping StateFunction
    ) {
        self.init(dimensions: dimensions, function: function) { state in
            let jacobian = NumericJacobian(rows: dimensions.state, columns: dimensions.state)
            return jacobian.numeric(state: state) { function($0) }
        }
    }

    public init(
        dimensions: StateDimensionsProtocol,
        function: @escaping StateFunction,
        jacobian: @escaping JacobianFunction
    ) {
        let dimensions = Dimensions(state: dimensions.state)
        self.dimensions = dimensions
        self.function = function
        self.jacobian = jacobian
    }
}

extension NonlinearMotionModel: MotionModelProtocol {
    public typealias State = Vector<Double>
    public typealias Dimensions = StateDimensions

    public func apply(state x: State) -> State {
        return self.function(x)
    }
}

extension NonlinearMotionModel: DifferentialMotionModel {
    public typealias Jacobian = Matrix<Double>

    public func jacobian(state x: State) -> Jacobian {
        return self.jacobian(x)
    }
}

extension NonlinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        typealias TypedDimensions = StateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard self.dimensions.state == typedDimensions.state else {
            throw DimensionsError.invalidValue(
                message: "Expected `self.dimensions.state == \(typedDimensions.state)`, found \(self.dimensions.state)"
            )
        }

        // To validate a function-defined model one needs to actually run it on some dummy data.
        // Given the obvious overhead of such a thorough check we choose to only run it on DEBUG builds:
        
        #if DEBUG
        let stateBefore = Vector(dimensions: typedDimensions.state, repeatedValue: 0.0)
        let stateAfter = self.apply(state: stateBefore)

        if stateAfter.dimensions != typedDimensions.state {
            throw VectorError.invalidDimensionCount(
                message: "Expected output vector of \(typedDimensions.state) dimensions, found \(stateAfter.dimensions)"
            )
        }
        #endif
    }
}
