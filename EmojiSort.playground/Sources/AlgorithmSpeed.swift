import Foundation

/// The speed at which an algorithm should be executed.
public enum AlgorithmSpeed:TimeInterval, CustomStringConvertible {
	case slow = 1.2
	case medium = 0.8
	case fast = 0.6
	case veryFast = 0.4
	
	public var description: String {
		switch self {
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
}
