import Foundation

/// The speed at which an algorithm should be executed.
public enum AlgorithmSpeed:TimeInterval, CustomStringConvertible {
	
	case verySlow = 1.2
	case slow = 0.8
	case medium = 0.55
	case fast = 0.35
	case veryFast = 0.23
	
	public var description: String {
		switch self {
		case .verySlow:
			return "Very Slow"
		case .slow:
			return "Slow"
		case .medium:
			return "Medium"
		case .fast:
			return "Fast"
		case .veryFast:
			return "Very Fast"
		}
	}
	
	public func next() -> AlgorithmSpeed {
		switch self {
		case .verySlow:
			return .slow
		case .slow:
			return .medium
		case .medium:
			return .fast
		case .fast:
			return .veryFast
		case .veryFast:
			return .verySlow
		}
	}
}
