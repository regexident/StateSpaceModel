import Foundation

import Surge

public class ControllableLinearMotionModel<UncontrolledMotionModel>
    where UncontrolledMotionModel: MotionModelProtocol
{
    public let uncontrolledModel: UncontrolledMotionModel
    public let control: Matrix<Double>

    public init(
        uncontrolledModel: UncontrolledMotionModel,
        control: Matrix<Double>
    ) {
        self.uncontrolledModel = uncontrolledModel
        self.control = control
    }
}

extension ControllableLinearMotionModel
    where UncontrolledMotionModel == LinearMotionModel
{
    public convenience init(
        state: Matrix<Double>,
        control: Matrix<Double>
    ) {
        let uncontrolledModel = UncontrolledMotionModel(state: state)

        assert(uncontrolledModel.state.shape == .square, "Expected square matrix")
        assert(uncontrolledModel.state.columns == control.rows, "State and control matrixes are not compatible")

        self.init(uncontrolledModel: uncontrolledModel, control: control)
    }
}

extension ControllableLinearMotionModel: StatefulModelProtocol
    where UncontrolledMotionModel: StatefulModelProtocol
{
    public typealias State = UncontrolledMotionModel.State
}

extension ControllableLinearMotionModel: ControllableModelProtocol {
    public typealias Control = Vector<Double>
}

extension ControllableLinearMotionModel: DifferentiableModelProtocol
    where UncontrolledMotionModel: DifferentiableModelProtocol
{
    public typealias Jacobian = UncontrolledMotionModel.Jacobian
}

extension ControllableLinearMotionModel: MotionModelProtocol {
    // Nothing
}

extension ControllableLinearMotionModel: UncontrollableMotionModelProtocol
    where UncontrolledMotionModel: UncontrollableMotionModelProtocol
{
    public func apply(state x: State) -> State {
        return self.uncontrolledModel.apply(state: x)
    }
}

extension ControllableLinearMotionModel: DifferentiableMotionModelProtocol
    where UncontrolledMotionModel: DifferentiableMotionModelProtocol
{
    public func jacobian(state x: State) -> Jacobian {
        return self.uncontrolledModel.jacobian(state: x)
    }
}

extension ControllableLinearMotionModel: ControllableMotionModelProtocol
    where UncontrolledMotionModel: UncontrollableMotionModelProtocol & StatefulModelProtocol,
          UncontrolledMotionModel.State == Control
{
    public func apply(state x: State, control u: Control) -> State {
        let xHat = self.apply(state: x)
        let b = self.control
        return xHat + (b * u)
    }
}

extension ControllableLinearMotionModel: ControllableDifferentiableMotionModelProtocol
    where UncontrolledMotionModel: DifferentiableMotionModelProtocol
{
    public func jacobian(state x: State, control u: Control) -> Jacobian {
        return self.jacobian(state: x)
    }
}

extension ControllableLinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        if let validatableModel = self.uncontrolledModel as? DimensionsValidatable {
            try validatableModel.validate(for: dimensions)
        }

        guard self.control.columns == dimensions.control else {
            throw MatrixError.invalidColumnCount(
                message: "Expected \(dimensions.control) columns in `self.control`, found \(self.control.columns)"
            )
        }

        guard self.control.rows == dimensions.state else {
            throw MatrixError.invalidRowCount(
                message: "Expected \(dimensions.state) columns in `self.control`, found \(self.control.rows)"
            )
        }
    }
}
