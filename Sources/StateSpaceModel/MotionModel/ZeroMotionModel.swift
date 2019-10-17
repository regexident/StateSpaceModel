import Foundation

import Surge
import StateSpace

public class ZeroMotionModel {
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

extension ZeroMotionModel: Statable {
    public typealias State = Vector<Double>
}

extension ZeroMotionModel: UncontrollableMotionModelProtocol {
   public func apply(state x: State) -> State {
        return x
    }
}

extension ZeroMotionModel: Differentiable {
    public typealias Jacobian = Matrix<Double>
}

extension ZeroMotionModel: DifferentiableMotionModelProtocol {
    public func jacobian(state x: State) -> Jacobian {
        return self.identity(size: x.dimensions)
    }
}

extension ZeroMotionModel: DimensionsValidatable {
    public func validate(for dimensions: DimensionsProtocol) throws {
        // This model cannot fail.
    }
}
