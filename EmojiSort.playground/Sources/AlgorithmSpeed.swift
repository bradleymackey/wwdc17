import Foundation

/// The speed at which an algorithm should be executed.
public enum AlgorithmSpeed: TimeInterval, CustomStringConvertible {
	
	case slow = 0.9
	case medium = 0.6
	case fast = 0.35
	
	public var description: String {
		switch self {
		case .slow:
			return "Slow"
		case .medium:
			return "Medium"
		case .fast:
			return "Fast"
		}
	}
	
	public func next() -> AlgorithmSpeed {
		switch self {
		case .slow:
			return .medium
		case .medium:
			return .fast
		case .fast:
			return .slow
		}
	}
}
