import Foundation

import Surge

public class ControllableLinearMotionModel {
    public let control: Matrix<Double>

    private let uncontrolledModel: LinearMotionModel

    public var state: Matrix<Double> {
        return self.uncontrolledModel.state
    }

    public init(
        state: Matrix<Double>,
        control: Matrix<Double>
    ) {
        assert(state.columns == control.rows, "State and control matrixes are not compatible")

        self.uncontrolledModel = LinearMotionModel(state: state)
        self.control = control
    }
}

extension ControllableLinearMotionModel: MotionModelProtocol {
    public typealias State = LinearMotionModel.State
    public typealias Dimensions = ControllableStateDimensions

    public var dimensions: Dimensions {
        // Given a square matrix it shouldn't matter
        // whether to return `matrix.rows` or `matrix.columns`:
        let state = self.state.rows
        let control = self.control.columns
        return Dimensions(state: state, control: control)
    }

    public func apply(state x: State) -> State {
        return self.uncontrolledModel.apply(state: x)
    }
}

extension ControllableLinearMotionModel: ControllableMotionModelProtocol {
    public typealias Control = Vector<Double>

    public func apply(state x: State, control u: Control?) -> State {
        let xHat = self.apply(state: x)

        guard let u = u else {
            return xHat
        }

        let b = self.control
        return xHat + (b * u)
    }
}

extension ControllableLinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        try self.uncontrolledModel.validate(for: dimensions)

        typealias TypedDimensions = StateDimensionsProtocol & ControlDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard self.control.columns == typedDimensions.control else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(typedDimensions.control) columns in `self.control`, found \(self.control.columns)"
            )
        }

        guard self.control.rows == typedDimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(typedDimensions.state) columns in `self.control`, found \(self.state.rows)"
            )
        }
    }
}
