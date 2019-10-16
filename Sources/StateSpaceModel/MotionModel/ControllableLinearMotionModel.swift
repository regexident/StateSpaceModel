import Foundation

import Surge

public class ControllableLinearMotionModel<UncontrolledMotionModel>
    where UncontrolledMotionModel: LinearMotionModel
{
    public let uncontrolledModel: UncontrolledMotionModel
    public let control: Matrix<Double>

    public init(
        uncontrolledModel: UncontrolledMotionModel,
        control: Matrix<Double>
    ) {
        assert(uncontrolledModel.state.shape == .square, "Expected square matrix")
        assert(uncontrolledModel.state.columns == control.rows, "State and control matrixes are not compatible")

        self.uncontrolledModel = uncontrolledModel
        self.control = control
    }
}

extension ControllableLinearMotionModel: DimensionalModelProtocol {
    public var dimensions: DimensionsProtocol {
        typealias TypedDimensions = StateDimensionsProtocol

        let dimensions = self.uncontrolledModel.dimensions
        guard let typedDimensions = dimensions as? TypedDimensions else {
            fatalError("Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)")
        }

        // Given a square matrix it shouldn't matter
        // whether to return `matrix.rows` or `matrix.columns`:
        let state = typedDimensions.state
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

extension ControllableLinearMotionModel: UncontrollableMotionModelProtocol {
    public func apply(state x: State) -> State {
        return self.uncontrolledModel.apply(state: x)
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
                message: "Expected \(typedDimensions.state) columns in `self.control`, found \(self.control.rows)"
            )
        }
    }
}
