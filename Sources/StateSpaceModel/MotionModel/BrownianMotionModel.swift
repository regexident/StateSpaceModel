import Foundation

import Surge
import StateSpace

public class BrownianMotionModel<MotionModel> {
    let motionModel: MotionModel

    public let stdDeviations: Vector<Double>

    public init(
        motionModel: MotionModel,
        stdDeviations: Vector<Double>
    ) {
        self.motionModel = motionModel
        self.stdDeviations = stdDeviations
    }

    private func applyBrownianMotion(state x: Vector<Double>) -> Vector<Double> {
        assert(x.dimensions == self.stdDeviations.dimensions)

        // Generate normal-distributed noise with standard deviation of 1.0:
        var prediction: Vector<Double> = .randomNormal(count: x.dimensions)

        // Scale noise to match provided standard deviations:
        prediction .*= self.stdDeviations

        // Add noise to state:
        prediction += x

        return prediction
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

        guard self.stdDeviations.dimensions == dimensions.state else {
            throw VectorError.invalidDimensionCount(
                message: "Expected \(dimensions.state) dimensions in `self.stdDeviations`, found \(self.stdDeviations.dimensions)"
            )
        }
    }
}
