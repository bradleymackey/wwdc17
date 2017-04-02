import Foundation
import UIKit


public protocol TeacherViewDelegate: class {
	/// triggered when blurs should be removed from any other views - we are ready to sort!
	func interactionReady(fadeDuration:TimeInterval)
}

/// The view module that contains the emoji teacher and their speech.
public final class TeacherView: UIView, OptionChangeReactable {
	
	// MARK: Static Constants
	
	public static let labelFlipFlopInterval: TimeInterval = 3
	
	// MARK: Enum
	
	public enum State {
		case welcomeSequence(currentPhraseIndex:Int)
		case infoAboutAlgorithms
	}
	
	// MARK: Delegate
	
	/// to notify other views of changes
	public weak var optionsDelegate:TeacherViewDelegate?
	public weak var sortViewDelegate:TeacherViewDelegate?
	
	// MARK: Properties
	
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
	
	private lazy var teacherLabel:TitleLabel = TitleLabel(position: CGPoint(x:self.center.x,y:2*self.frame.height/3), initialText: "Uh oh...", initialStyle:.narratorTalk, maxSize: CGSize(width: self.frame.width-10, height: self.frame.height/2))
	private var teacherInitiallyTouched = false
	
	private var currentState:State = .welcomeSequence(currentPhraseIndex: 0)
	

	// MARK: Init

	public init(frame:CGRect, teacher:EmojiTeacher) {
		
		self.teacher = teacher
		
		self.collisionBehavior = UICollisionBehavior(items: [])
		self.collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		self.gravityBehavior = UIGravityBehavior(items: [])
		self.zLabelBehavior = UIDynamicItemBehavior(items: [])
		self.zLabelBehavior.elasticity = 0.2
		self.zLabelBehavior.density = 0.4
		
		super.init(frame: frame)
		
		self.animator = UIDynamicAnimator(referenceView: self)
		self.animator?.addBehavior(collisionBehavior)
		self.animator?.addBehavior(gravityBehavior)
		self.animator?.addBehavior(zLabelBehavior)
		
		self.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.5, blue: 1, alpha: 1)
		self.clipsToBounds = true
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
		
		self.addSubview(teacherLabel)
		self.teacherLabel.startFlipFlop(duration: 3, position: teacherLabel.center, firstStyle: .narratorTalk, firstText: "Uh oh...", secondStyle: .userInteractionPrompt, secondText: "Tap the teacher.")
	}
	
	private func teacherStartSnoring() {
		snoringTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [unowned self] (timer) in
			let snoreLabel = UILabel(frame: .zero)
			snoreLabel.textAlignment = .center
			snoreLabel.center = CGPoint(x: self.teacher.center.x, y: self.teacher.center.y-10)
			snoreLabel.text = "z"
			snoreLabel.textColor = .white
			snoreLabel.font = UIFont.systemFont(ofSize: CGFloat(arc4random_uniform(4)+6))
			snoreLabel.sizeToFit()
			self.zLabels.insert(snoreLabel, at: 0)
			self.addSubview(snoreLabel)
			self.gravityBehavior.addItem(snoreLabel)
			self.collisionBehavior.addItem(snoreLabel)
			self.zLabelBehavior.addItem(snoreLabel)
			self.zLabelBehavior.addLinearVelocity(CGPoint(x: CGFloat(Int(arc4random_uniform(400))-200), y: -250), for: snoreLabel)
		}
	}
	
	// MARK: Touches
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		if teacher.frame.contains(location) {
			defer { updateLabelForCurrentState() }
			guard !teacherInitiallyTouched else { return }
			teacherInitiallyTouched = true
			// stop the teacher from snoring
			snoringTimer?.invalidate()
			teacher.bounce(1, completion: nil)
			teacher.currentEmotion = .unimpressed
			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
				DispatchQueue.main.async {
					self.teacher.shake {
						self.teacher.currentEmotion = .talking
					}
				}
			}
		}
	}
	
	private func updateLabelForCurrentState() {
		teacherLabel.stopFlipFlop()
		switch currentState {
		case .welcomeSequence(let currentIndex):
			guard currentIndex < teacher.introPhrases.count else {
				currentState = .infoAboutAlgorithms
				teacher.currentEmotion = .love
				self.optionsDelegate?.interactionReady(fadeDuration: 2)
				self.sortViewDelegate?.interactionReady(fadeDuration: 2)
				break
			}
			defer { currentState = .welcomeSequence(currentPhraseIndex: currentIndex+1) }
			self.teacherLabel.animateTitle(to: .teacherTalk, position: self.teacherLabel.center, text: teacher.introPhrases[currentIndex])
		case .infoAboutAlgorithms:
			self.teacher.currentEmotion = .shocked
			self.teacherLabel.animateTitle(to: .teacherTalk, position: self.teacherLabel.center, text: "Ouch!")
		}
	}
	
	// MARK: Delegate
	
	public func sort(withAlgorithm algorithm: Sorter.Algorithm, trait: Emoji.Trait, speed: AlgorithmSpeed) {
		
	}
	
	public func randomisePositions() {
		teacher.currentEmotion = .cool
		teacherLabel.animateTitle(to: .narratorTalk, position: teacherLabel.center, text: "Let's mix things up!")
	}
	
	public func newTraitTapped(trait: Emoji.Trait) {
		fatalError("'TeacherView' does not need to respond to 'newTraitTapped' events.")
	}
	
	public func newAlgorithmTapped(algorithm: Sorter.Algorithm) {
		// emoji teacher should briefly explain algorithm before we use it
		switch algorithm {
		case .bubbleSort:
			teacher.currentEmotion = .unimpressed
			teacherLabel.animateTitle(to: .teacherTalk, position: teacherLabel.center, text: "Bubble Sort? Seriously? Smh.")
		case .insertionSort:
			teacher.currentEmotion = .cool
			teacherLabel.animateTitle(to: .teacherTalk, position: teacherLabel.center, text: "Good for short lists!")
		case .mergeSort:
			teacher.currentEmotion = .love
			teacherLabel.animateTitle(to: .teacherTalk, position: teacherLabel.center, text: "One of the most efficient sorting algorithms!!!")
		case .selectionSort:
			teacher.currentEmotion = .unimpressed
			teacherLabel.animateTitle(to: .teacherTalk, position: teacherLabel.center, text: "I've seen better sorting algorithms...")
		case .stupidSort:
			teacher.currentEmotion = .shocked
			teacherLabel.animateTitle(to: .teacherTalk, position: teacherLabel.center, text: "Let's just not even go there...")
		}
	}
	
	
}

