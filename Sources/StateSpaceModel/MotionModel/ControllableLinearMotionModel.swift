import Foundation

import Surge
import StateSpace

public class ControllableLinearMotionModel<MotionModel>
    where MotionModel: MotionModelProtocol
{
    public let motionModel: MotionModel
    public let control: Matrix<Double>

    public init(
        motionModel: MotionModel,
        control: Matrix<Double>
    ) {
        self.motionModel = motionModel
        self.control = control
    }
}

extension ControllableLinearMotionModel
    where MotionModel == LinearMotionModel
{
    public convenience init(
        state: Matrix<Double>,
        control: Matrix<Double>
    ) {
        let motionModel = MotionModel(state: state)

        assert(motionModel.state.shape == .square, "Expected square matrix")
        assert(motionModel.state.columns == control.rows, "State and control matrixes are not compatible")

        self.init(motionModel: motionModel, control: control)
    }
}

extension ControllableLinearMotionModel: Statable
    where MotionModel: Statable
{
    public typealias State = MotionModel.State
}

extension ControllableLinearMotionModel: Controllable {
    public typealias Control = Vector<Double>
}

extension ControllableLinearMotionModel: Differentiable
    where MotionModel: Differentiable
{
    public typealias Jacobian = MotionModel.Jacobian
}

extension ControllableLinearMotionModel: MotionModelProtocol {
    // Nothing
}

extension ControllableLinearMotionModel: ControllableMotionModelProtocol
    where MotionModel: UncontrollableMotionModelProtocol & Statable,
          MotionModel.State == Control
{
    public func apply(state x: State, control u: Control) -> State {
        let xHat = self.motionModel.apply(state: x)
        let b = self.control
        return xHat + (b * u)
    }
}

extension ControllableLinearMotionModel: ControllableDifferentiableMotionModelProtocol
    where MotionModel: DifferentiableMotionModelProtocol
{
    public func jacobian(state x: State, control u: Control) -> Jacobian {
        return self.motionModel.jacobian(state: x)
    }
}

extension ControllableLinearMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        if let validatableModel = self.motionModel as? DimensionsValidatable {
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
