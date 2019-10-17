import Foundation

import Surge

public class BrownianMotionModel<MotionModel> {
    let model: MotionModel

    public let noise: Vector<Double>

    public init(
        model: MotionModel,
        noise: Vector<Double>
    ) {
        self.model = model
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

extension BrownianMotionModel: StatefulModelProtocol
    where MotionModel: StatefulModelProtocol
{
    public typealias State = MotionModel.State
}

extension BrownianMotionModel: ControllableModelProtocol
    where MotionModel: ControllableModelProtocol
{
    public typealias Control = MotionModel.Control
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
        let xHat = self.model.apply(state: x)
        return self.applyBrownianMotion(state: xHat)
    }
}

extension BrownianMotionModel: ControllableMotionModelProtocol
    where MotionModel: ControllableMotionModelProtocol, MotionModel.State == Vector<Double>
{
    public func apply(state x: State, control u: Control) -> State {
        let xHat = self.model.apply(state: x, control: u)
        return self.applyBrownianMotion(state: xHat)
    }
}

extension BrownianMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        if let validatableModel = self.model as? DimensionsValidatable {
            try validatableModel.validate(for: dimensions)
        }

        guard self.noise.dimensions == dimensions.state else {
            throw VectorError.invalidDimensionCount(
                message: "Expected \(dimensions.state) dimensions in `self.noise`, found \(self.noise.dimensions)"
            )
        }
    }
}
