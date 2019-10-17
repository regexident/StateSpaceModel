import Foundation

public protocol DimensionsProtocol {
    var state: Int { get }
    var control: Int { get }
    var observation: Int { get }
}

public struct Dimensions: DimensionsProtocol, Hashable, Equatable {
    public let state: Int
    public let control: Int
    public let observation: Int

    public init(state: Int, control: Int, observation: Int) {
        assert(state >= 1)
        assert(control >= 0)
        assert(observation >= 0)

        self.state = state
        self.control = control
        self.observation = observation
    }
}

extension Dimensions: CustomStringConvertible {
    public var description: String {
        var propertiesString = "state: \(self.state)"

        if self.control > 0 {
            propertiesString += "control: \(self.observation)"
        }

        if self.observation > 0 {
            propertiesString += "observation: \(self.observation)"
        }

        return "{ \(propertiesString) }"
    }
}
