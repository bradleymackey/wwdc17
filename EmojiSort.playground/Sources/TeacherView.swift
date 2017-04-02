import Foundation
import UIKit

/// The view module that contains the emoji teacher and their speech.
public final class TeacherView: UIView, OptionChangeReactable {
	
	// MARK: Static Constants
	
	public static let labelFlipFlopInterval: TimeInterval = 3
	
	
	// MARK: Properties
	
	private var currentSceneChapter:SceneChapter = .welcome
	
	private var teacher:EmojiTeacher
	
	private var animator: UIDynamicAnimator?

	
	private let collisionBehavior: UICollisionBehavior
	private let gravityBehavior: UIGravityBehavior
	private let zLabelBehavior: UIDynamicItemBehavior
	
	private var snoringTimer:Timer?
	
	private var zLabels = [UILabel]() {
		didSet {
			// only cleanup if we added a label since last time
			guard zLabels.count > oldValue.count else { return }
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
				// only remove from the array if there is at least 1 element in the array
				guard let label = self.zLabels.popLast() else { return }
				UIView.animate(withDuration: 1, animations: {
					label.alpha = 0
				}, completion: { (completed) in
					self.gravityBehavior.removeItem(label)
					self.zLabelBehavior.removeItem(label)
					self.collisionBehavior.removeItem(label)
					label.removeFromSuperview()
				})
			}
		}
	}
	
	// MARK: Init

	public init(frame:CGRect, teacher:EmojiTeacher) {
		
		self.teacher = teacher
		
		self.collisionBehavior = UICollisionBehavior(items: [])
		self.collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		self.gravityBehavior = UIGravityBehavior(items: [])
		self.zLabelBehavior = UIDynamicItemBehavior(items: [])
		self.zLabelBehavior.elasticity = 0.4
		
		super.init(frame: frame)
		
		self.animator = UIDynamicAnimator(referenceView: self)
		self.animator?.addBehavior(collisionBehavior)
		self.animator?.addBehavior(gravityBehavior)
		self.animator?.addBehavior(zLabelBehavior)
		
		self.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.5, blue: 1, alpha: 1)
		self.layer.borderWidth = 0.5
		self.layer.borderColor = UIColor.black.cgColor
		
		setupElements()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Setup Methods
	
	private func setupElements() {
		teacher.center = CGPoint(x: self.center.x, y: self.frame.height/3)
		self.addSubview(teacher)
		
		self.teacherStartSnoring()
	}
	
	private func teacherStartSnoring() {
		snoringTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [unowned self] (timer) in
			let snoreLabel = UILabel(frame: .zero)
			snoreLabel.textAlignment = .center
			snoreLabel.center = CGPoint(x: self.teacher.center.x, y: self.teacher.center.y-10)
			snoreLabel.text = "z"
			snoreLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(arc4random_uniform(5)+10))
			snoreLabel.sizeToFit()
			self.zLabels.insert(snoreLabel, at: 0)
			self.addSubview(snoreLabel)
			self.gravityBehavior.addItem(snoreLabel)
			self.collisionBehavior.addItem(snoreLabel)
			self.zLabelBehavior.addItem(snoreLabel)
			self.zLabelBehavior.addLinearVelocity(CGPoint(x: CGFloat(Int(arc4random_uniform(400))-200), y: -450), for: snoreLabel)
		}
	}
	
	// MARK: Delegate
	
	public func sort(withAlgorithm algorithm: Sorter.Algorithm, trait: Emoji.Trait, speed: AlgorithmSpeed) {
		
	}
	
	public func randomisePositions() {
		
	}
	
	public func newTraitTapped(trait: Emoji.Trait) {
		fatalError("'TeacherView' does not need to respond to 'newTraitTapped' events.")
	}
	
	public func newAlgorithmTapped(algorithm: Sorter.Algorithm) {
		// emoji teacher should briefly explain algorithm before we use it
	}
	
	
}

