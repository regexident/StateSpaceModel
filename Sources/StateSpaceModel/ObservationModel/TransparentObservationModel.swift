import Foundation

import Surge
import StateSpace

public class TransparentObservationModel {
    private var cachedIdentity: Matrix<Double>? = nil

    public init() {
        // nothing
    }

    private func identity(size: Int) -> Matrix<Double> {
        let identity = self.cachedIdentity ?? Matrix.identity(size: size)

        assert(identity.rows == size, "Malformed identity matrix")
        assert(identity.columns == size, "Malformed identity matrix")

        self.cachedIdentity = identity

        return identity
    }
}

extension TransparentObservationModel: Statable {
    public typealias State = Vector<Double>
}

extension TransparentObservationModel: Observable {
    public typealias Observation = Vector<Double>
}

extension TransparentObservationModel: ObservationModelProtocol {
   public func apply(state x: State) -> Observation {
        return x
    }
}

extension TransparentObservationModel: Differentiable {
    public typealias Jacobian = Matrix<Double>
}

extension TransparentObservationModel: DifferentiableObservationModelProtocol {
    public func jacobian(state x: State) -> Jacobian {
        return self.identity(size: x.dimensions)
    }
}

extension TransparentObservationModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        guard dimensions.state == dimensions.observation else {
            throw DimensionsError.invalidValue(
                message: "Expected `dimension.state == dimensions.observation, found `\(dimensions.state) != \(dimensions.observation)"
            )
        }
    }
}
