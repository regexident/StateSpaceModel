import Foundation

import Surge
import StateSpace

public class BrownianMotionModel<MotionModel> {
    let motionModel: MotionModel

    public let noise: Vector<Double>

    public init(
        motionModel: MotionModel,
        noise: Vector<Double>
    ) {
        self.motionModel = motionModel
        self.noise = noise
    }

    private func applyBrownianMotion(state x: Vector<Double>) -> Vector<Double> {
        fatalError("Unimplemented")

        // FIXME: generate normal-distributed noise displacement vector
        // with with mean `0.0` and individual std-deviations from `self.noise`,

        // let y = self.noise
        // return x + y
    }
}

extension BrownianMotionModel: Statable
    where MotionModel: Statable
{
    public typealias State = MotionModel.State
}

extension BrownianMotionModel: Controllable
    where MotionModel: Controllable
{
    public typealias Control = MotionModel.Control
}

extension BrownianMotionModel: Differentiable
    where MotionModel: Differentiable
{
    public typealias Jacobian = MotionModel.Jacobian
}

extension BrownianMotionModel: DifferentiableMotionModelProtocol
    where MotionModel: DifferentiableMotionModelProtocol
{
    public func jacobian(state x: State) -> Jacobian {
        return self.motionModel.jacobian(state: x)
    }
}

extension BrownianMotionModel: ControllableDifferentiableMotionModelProtocol
    where MotionModel: ControllableDifferentiableMotionModelProtocol
{
    public func jacobian(state x: State, control u: Control) -> Jacobian {
        return self.motionModel.jacobian(state: x, control: u)
    }
}

extension BrownianMotionModel: MotionModelProtocol
    where MotionModel: MotionModelProtocol
{
    // Nothing
}

extension BrownianMotionModel: UncontrollableMotionModelProtocol
    where MotionModel: UncontrollableMotionModelProtocol, MotionModel.State == Vector<Double>
{
    public func apply(state x: State) -> State {
        let xHat = self.motionModel.apply(state: x)
        return self.applyBrownianMotion(state: xHat)
    }
}

extension BrownianMotionModel: ControllableMotionModelProtocol
    where MotionModel: ControllableMotionModelProtocol, MotionModel.State == Vector<Double>
{
    public func apply(state x: State, control u: Control) -> State {
        let xHat = self.motionModel.apply(state: x, control: u)
        return self.applyBrownianMotion(state: xHat)
    }
}

extension BrownianMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        if let validatableModel = self.motionModel as? DimensionsValidatable {
            try validatableModel.validate(for: dimensions)
        }

        guard self.noise.dimensions == dimensions.state else {
            throw VectorError.invalidDimensionCount(
                message: "Expected \(dimensions.state) dimensions in `self.noise`, found \(self.noise.dimensions)"
            )
        }
    }
}
