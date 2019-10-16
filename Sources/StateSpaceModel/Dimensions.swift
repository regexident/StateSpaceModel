import Foundation

public protocol DimensionsProtocol {

}

/// Describes a state-space model.
///
/// "In control engineering, a state-space representation is a mathematical model of a physical system as a set of input, output and state variables related by first-order differential equations or difference equations." – [Wikipedia](https://en.wikipedia.org/wiki/State-space_representation)
public protocol StateDimensionsProtocol: DimensionsProtocol {
    var state: Int { get }
}

/// Describes a state-space model satisfies the condition of state controllability.
///
/// "The state controllability condition implies that it is possible – by admissible inputs – to steer the states from any initial value to any final value within some finite time window." – [Wikipedia](https://en.wikipedia.org/wiki/State-space_representation#Controllability)
public protocol ControlDimensionsProtocol: DimensionsProtocol {
    var control: Int { get }
}

/// Describes a state-space model satisfies the condition of state observability.
///
/// "Observability is a measure for how well internal states of a system can be inferred by knowledge of its external outputs." – [Wikipedia](https://en.wikipedia.org/wiki/State-space_representation#Observability)
public protocol ObservationDimensionsProtocol: DimensionsProtocol {
    var observation: Int { get }
}

public typealias ControlledStateDimensionsProtocol = StateDimensionsProtocol & ControlDimensionsProtocol
public typealias ObservedStateDimensionsProtocol = StateDimensionsProtocol & ObservationDimensionsProtocol

public struct StateDimensions: StateDimensionsProtocol, Hashable, Equatable {
    public let state: Int

    public init(state: Int) {
        assert(state >= 1)

        self.state = state
    }
}

extension StateDimensions: CustomStringConvertible {
    public var description: String {
        return "{ state: \(self.state) }"
    }
}

public struct ControllableStateDimensions: StateDimensionsProtocol, ControlDimensionsProtocol, Hashable, Equatable {
    public let state: Int
    public let control: Int

    public init(state: Int, control: Int) {
        assert(state >= 1)
        assert(control >= 1)

        self.state = state
        self.control = control
    }
}

extension ControllableStateDimensions: CustomStringConvertible {
    public var description: String {
        return "{ state: \(self.state), control: \(self.control) }"
    }
}

public struct ObservableStateDimensions: StateDimensionsProtocol, ObservationDimensionsProtocol, Hashable, Equatable {
    public let state: Int
    public let observation: Int

    public init(state: Int, observation: Int) {
        assert(state >= 1)
        assert(observation >= 1)

        self.state = state
        self.observation = observation
    }
}

extension ObservableStateDimensions: CustomStringConvertible {
    public var description: String {
        return "{ state: \(self.state), observation: \(observation) }"
    }
}

public struct ControllableObservableStateDimensions: StateDimensionsProtocol, ControlDimensionsProtocol, ObservationDimensionsProtocol, Hashable, Equatable {
    public let state: Int
    public let control: Int
    public let observation: Int

    public init(state: Int, control: Int, observation: Int) {
        assert(state >= 1)
        assert(control >= 1)
        assert(observation >= 1)

        self.state = state
        self.control = control
        self.observation = observation
    }
}

extension ControllableObservableStateDimensions: CustomStringConvertible {
    public var description: String {
        return "{ state: \(self.state), control: \(self.control), observation: \(observation) }"
    }
}
