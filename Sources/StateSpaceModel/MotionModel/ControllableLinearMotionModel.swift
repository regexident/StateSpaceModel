import Foundation

import Surge

public class ControllableLinearMotionModel<UncontrolledMotionModel>
    where UncontrolledMotionModel: LinearMotionModel
{
    public let state: Matrix<Double>
    public let control: Matrix<Double>

    public init(
        state: Matrix<Double>,
        control: Matrix<Double>
    ) {
        assert(state.shape == .square, "Expected square matrix")
        assert(state.columns == control.rows, "State and control matrixes are not compatible")

        self.state = state
        self.control = control
    }
}

extension ControllableLinearMotionModel: DimensionalModelProtocol {
    public var dimensions: DimensionsProtocol {
        // Given a square matrix it shouldn't matter
        // whether to return `matrix.rows` or `matrix.columns`:
        let state = self.state.rows
        let control = self.control.columns
        return ControllableStateDimensions(state: state, control: control)
    }
}

extension ControllableLinearMotionModel: StatefulModelProtocol {
    public typealias State = LinearMotionModel.State
}

extension ControllableLinearMotionModel: ControllableModelProtocol {
    public typealias Control = Vector<Double>
}

extension ControllableLinearMotionModel: MotionModelProtocol {
    public func apply(state x: State) -> State {
        let a = self.state
        return a * x
    }
}

extension ControllableLinearMotionModel: ControllableMotionModelProtocol {
    public func apply(state x: State, control u: Control) -> State {
        let xHat = self.apply(state: x)
        let b = self.control
        return xHat + (b * u)
    }
}

extension ControllableLinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        typealias TypedDimensions = StateDimensionsProtocol & ControlDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard self.state.columns == typedDimensions.state else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(typedDimensions.state) columns in `self.state`, found \(self.state.columns)"
            )
        }

        guard self.state.rows == typedDimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(typedDimensions.state) columns in `self.state`, found \(self.state.rows)"
            )
        }

        guard self.control.columns == typedDimensions.control else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(typedDimensions.control) columns in `self.control`, found \(self.control.columns)"
            )
        }

        guard self.control.rows == typedDimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(typedDimensions.state) columns in `self.control`, found \(self.control.rows)"
            )
        }
    }
}
