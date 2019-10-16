import Foundation

import Surge

public class BrownianMotionModel<MotionModel>
    where MotionModel: DimensionalModelProtocol
{
    let model: MotionModel

    public let noise: Vector<Double>

    public init(
        model: MotionModel,
        noise: Vector<Double>
    ) {
        typealias TypedDimensions = StateDimensionsProtocol
        guard let dimensions = model.dimensions as? TypedDimensions else {
            assert(false, "Type \(type(of: model.dimensions)) does not conform to \(TypedDimensions.self)")
        }

        // Given a square matrix it doesn't matter
        // whether to check against `noise.rows` or `noise.columns`:
        assert(dimensions.state == noise.dimensions, "State matrix not compatible with noise vector")

        self.model = model
        self.noise = noise
    }

    private func applyBrownianMotion(state x: Vector<Double>) -> Vector<Double> {
        // FIXME: generate normal-distributed noise displacement vector
        // with with mean `0.0` and individual std-deviations from `self.noise`,
        let y = self.noise
        return x + y
    }
}

extension BrownianMotionModel: DimensionalModelProtocol
    where MotionModel: DimensionalModelProtocol
{
    public var dimensions: DimensionsProtocol {
        return self.model.dimensions
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
    where MotionModel: MotionModelProtocol, MotionModel.State == Vector<Double>
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

extension BrownianMotionModel: DimensionsValidatable
    where MotionModel: DimensionsValidatable
{
    public func validate(for dimensions: DimensionsProtocol) throws {
        try self.model.validate(for: dimensions)

        typealias TypedDimensions = StateDimensionsProtocol

        guard let typedDimensions = dimensions as? TypedDimensions else {
            throw DimensionsError.invalidType(
                message: "Type \(type(of: dimensions)) does not conform to \(TypedDimensions.self)"
            )
        }

        guard self.noise.dimensions == typedDimensions.state else {
            throw VectorError.invalidDimensionCount(
                message: "Expected \(typedDimensions.state) dimensions in `self.noise`, found \(self.noise.dimensions)"
            )
        }
    }
}
