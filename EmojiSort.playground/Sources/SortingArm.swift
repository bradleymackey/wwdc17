import Foundation
import UIKit

/// The arm the the claws attach to.
fileprivate final class Stalk:UILabel {
	
	fileprivate init() {
		super.init(frame: .zero)
		self.text = "|"
		self.textColor = .black
		self.font = UIFont(name: "AvenirNextCondensed-UltraLight", size: 200)
		self.textAlignment = .center
		self.sizeToFit()
	}
	
	required fileprivate init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

/// the jaws of the claw that do the grabbing.
fileprivate final class Claw:UILabel {
	
	// MARK: Properities
	
	fileprivate enum Side:String {
		case left = "{"
		case right = "}"
	}
	
	// MARK: Init
	
	fileprivate init(side:Side) {
		super.init(frame: .zero)
		self.text = side.rawValue
		self.textColor = .black
		self.textAlignment = .center
		self.font = UIFont(name: "AvenirNextCondensed-Medium", size: 30)
		self.sizeToFit()
	}
	
	required fileprivate init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

/// The animated arm that the user thinks does the actual sorting of the emojis.
public final class SortingArm: UIView {
	
	// MARK: Constants
	
	public static let openedAngle:CGFloat = 0.6
	public static let grabbedAngle:CGFloat = 0.35
	
	// MARK: Claw Elements
	
	private var leftClaw = Claw(side: .left)
	private var rightClaw = Claw(side: .right)
	private var stalk = Stalk()
	
	private var grabSpeed:TimeInterval
	
	// MARK: Claw State
	
	public enum ClawState {
		case open
		case grabbed
		case closed
		
		public func next() -> ClawState {
			switch self {
			case .open:
				return .grabbed
			case .grabbed:
				return .closed
			case .closed:
				return .open
			}
		}
	}
	
	public var clawState:ClawState = .closed {
		didSet {
			guard clawState != oldValue else { return }
			DispatchQueue.main.async { [clawState] in
				self.layer.removeAllAnimations()
				UIView.animate(withDuration: self.grabSpeed, delay: 0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.07, options: [.curveEaseOut], animations: { [clawState] in
					self.adjustClawPositions(forNewState: clawState)
					self.leftClaw.transform = self.clawAnimationTransform(side: .left, state: clawState)
					self.rightClaw.transform = self.clawAnimationTransform(side: .right, state: clawState)
					}, completion: nil)
			}
		}
	}
	
	
	/// the point where the claws grab
	public var targetLocation:CGPoint {
		get {
			let y = self.leftClaw.center.y-3
			let x = (self.leftClaw.center.x+self.rightClaw.center.x)/2
			return CGPoint(x: x, y: y)
		}
		set {
			// get in terms of the center of the view
			let diffX = targetLocation.x-(self.bounds.width/2)
			let diffY = targetLocation.y-(self.bounds.height/2)
			let actualX = newValue.x-diffX
			let actualY = newValue.y-diffY
			// set the center to be this point
			self.center = CGPoint(x: actualX, y: actualY)
		}
	}
	
	// MARK: Init
	
	public init(grabSpeed:TimeInterval) {
		self.grabSpeed = grabSpeed
		super.init(frame: CGRect(x: 0, y: 0, width: 60, height: 200))
		
		self.backgroundColor = .clear
		
		setupClawElementPositions()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	private func setupClawElementPositions() {
		stalk.center = self.center
		adjustClawPositions(forNewState: clawState)
		self.addSubview(stalk)
		self.addSubview(leftClaw)
		self.addSubview(rightClaw)
	}
	
	private func clawAnimationTransform(side:Claw.Side,state:ClawState) -> CGAffineTransform {
		var angle = angleForState(state: state)
		if side == .right { angle *= -1 }
		return CGAffineTransform(rotationAngle: angle)
	}
	
	private func angleForState(state:ClawState) -> CGFloat {
		switch state {
		case .open:
			return SortingArm.openedAngle
		case .grabbed:
			return SortingArm.grabbedAngle
		case .closed:
			return 0
		}
	}
	
	private func adjustClawPositions(forNewState state:ClawState) {
		let offset:CGFloat = {
			switch state {
			case .open:
				return 9
			case .grabbed:
				return 6
			case .closed:
				return 3
			}
		}()
		leftClaw.center = CGPoint(x: self.stalk.center.x-offset, y: self.stalk.frame.height-51)
		rightClaw.center = CGPoint(x: self.stalk.center.x+offset, y: self.stalk.frame.height-51)
	}
	
}

