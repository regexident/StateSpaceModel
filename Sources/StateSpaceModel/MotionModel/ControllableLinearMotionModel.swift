import Foundation

import Surge
import StateSpace

public class ControllableLinearMotionModel<MotionModel, ControlModel>
    where MotionModel: MotionModelProtocol,
          ControlModel: ControlModelProtocol
{
    public let motionModel: MotionModel
    public let controlModel: ControlModel

    public init(
        motionModel: MotionModel,
        controlModel: ControlModel
    ) {
        self.motionModel = motionModel
        self.controlModel = controlModel
    }
}

extension ControllableLinearMotionModel
    where MotionModel == LinearMotionModel,
          ControlModel == LinearControlModel
{
    public convenience init(
        a: Matrix<Double>,
        b: Matrix<Double>
    ) {
        let motionModel = MotionModel(a: a)
        let controlModel = ControlModel(b: b)

        assert(motionModel.a.shape == .square, "Expected square matrix")
        assert(motionModel.a.columns == controlModel.b.rows, "State and control matrixes are not compatible")

        self.init(
            motionModel: motionModel,
            controlModel: controlModel
        )
    }
}

extension ControllableLinearMotionModel: Statable
    where MotionModel: Statable
{
    public typealias State = MotionModel.State
}

extension ControllableLinearMotionModel: Controllable {
    public typealias Control = ControlModel.Control
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
    where MotionModel: UncontrollableMotionModelProtocol,
          ControlModel: ControlModelProtocol,
          MotionModel.State == Vector<Double>,
		  ControlModel.State == Vector<Double>,
          ControlModel.Control == Vector<Double>
{
    public func apply(state x: State, control u: Control) -> State {
        let xHat = self.motionModel.apply(state: x)
        let uHat = self.controlModel.apply(control: u)
        return xHat + uHat
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
        if let motionModel = self.motionModel as? DimensionsValidatable {
            try motionModel.validate(for: dimensions)
        }

        if let controlModel = self.controlModel as? DimensionsValidatable {
            try controlModel.validate(for: dimensions)
        }
    }
}
