import Foundation
import UIKit


/// To be adopted by any reciever that wants to recieve info about when the user selects a new algorithm, trait or speed.
public protocol OptionChangeReactable: class {
	func sort(withAlgorithm algorithm:Sorter.Algorithm, trait: Emoji.Trait, speed: AlgorithmSpeed)
	func randomisePositions()
	/// so the EmojiSortView can update the bar chart
	func newTraitTapped(trait:Emoji.Trait)
	/// so the emoji teacher can give a bit of explaination before we see it in action
	func newAlgorithmTapped(algorithm:Sorter.Algorithm)
}


public final class OptionView: UIView, EmojiSortViewDelegate, TeacherViewDelegate {
	
	// MARK: Delegate
	
	public weak var sortDelegate:OptionChangeReactable?
	public weak var teacherDelegate:OptionChangeReactable?
	
	// MARK: Labels
	
	// setup performed once `self` has initalised
	
	private var traitLabel = UILabel(frame: .zero)
	private var algorithmLabel = UILabel(frame: .zero)
	private var speedLabel = UILabel(frame: .zero)
	
	// MARK: Buttons
	
	// setup performed once `self` has initalised
	
	private var traitButton = UIButton(type: .system)
	private var algorithmButton = UIButton(type: .system)
	private var speedButton = UIButton(type: .system)
	
	private var sortButton = UIButton(type: .system)
	private var randomiseButton = UIButton(type: .system)
	
	private var allButtons:[UIButton] {
		return [traitButton,algorithmButton,speedButton,sortButton,randomiseButton]
	}
	
	// MARK: State
	
	private var currentAlgorithm:Sorter.Algorithm = .bubbleSort
	private var currentTrait:Emoji.Trait = .happiness
	private var currentSpeed:AlgorithmSpeed = .medium
	
	// MARK: Blur View
	
	private lazy var effectView: UIVisualEffectView = UIVisualEffectView(frame: self.bounds)
	
	// MARK: Init
	
	public override init(frame:CGRect) {
		
		super.init(frame: frame)
		
		self.backgroundColor = .white
		self.layer.borderWidth = 0.5
		self.layer.borderColor = UIColor.black.cgColor
		
		setupLabels()
		setupButtons()
		setupButtonActions()
		setupBlur()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: Methods
	
	private func setupBlur() {
		effectView.effect = UIBlurEffect(style: .light)
		self.addSubview(effectView)
	}
	
	private func setupLabels() {
		var currentOffsetMultiplier = 1
		let traitTitles = ["Trait", "Algorithm", "Speed"]
		[traitLabel,algorithmLabel,speedLabel].forEach { label in
			defer { currentOffsetMultiplier += 1 }
			label.text = traitTitles[currentOffsetMultiplier-1]
			label.font = UIFont.systemFont(ofSize: 9)
			label.textColor = .darkGray
			label.textAlignment = .center
			label.sizeToFit()
			label.center = CGPoint(x: self.frame.width/2, y: (CGFloat(currentOffsetMultiplier)*(self.frame.height/5))-12)
			self.addSubview(label)
		}
	}
	
	private func setupButtons() {
		var currentOffsetMultiplier = 1
		let states:[CustomStringConvertible] = [currentTrait,currentAlgorithm,currentSpeed]
		[traitButton,algorithmButton,speedButton].forEach { button in
			defer { currentOffsetMultiplier += 1 }
			button.setTitle(states[currentOffsetMultiplier-1].description, for: .normal)
			button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			button.titleLabel?.minimumScaleFactor = 0.5
			button.sizeToFit()
			button.center = CGPoint(x: self.frame.width/2, y: (CGFloat(currentOffsetMultiplier)*(self.frame.height/5)))
			self.addSubview(button)
		}
		
		currentOffsetMultiplier = 1
		let extraButtonTitles = ["Randomise","Sort"]
		[randomiseButton,sortButton].forEach { button in
			defer { currentOffsetMultiplier += 1 }
			button.setTitle(extraButtonTitles[currentOffsetMultiplier-1], for: .normal)
			button.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: 3)
			button.sizeToFit()
			button.center = CGPoint(x: CGFloat(currentOffsetMultiplier)*self.frame.width/3, y: 4*(self.frame.height/5))
			self.addSubview(button)
		}
	}
	
	private func setupButtonActions() {
		traitButton.addTarget(self, action: #selector(OptionView.traitButtonPressed), for: .touchUpInside)
		algorithmButton.addTarget(self, action: #selector(OptionView.algorithmButtonPressed), for: .touchUpInside)
		speedButton.addTarget(self, action: #selector(OptionView.speedButtonPressed), for: .touchUpInside)
		
		randomiseButton.addTarget(self, action: #selector(OptionView.randomiseButtonPressed), for: .touchUpInside)
		sortButton.addTarget(self, action: #selector(OptionView.sortButtonPressed), for: .touchUpInside)
	}
	
	
	// MARK: Button Actions
	
	@objc private func traitButtonPressed() {
		currentTrait = currentTrait.next()
		traitButton.setTitle(currentTrait.description, for: .normal)
		let prevCenter = traitButton.center
		traitButton.sizeToFit()
		traitButton.center = prevCenter
		
		self.sortDelegate?.newTraitTapped(trait: currentTrait)
	}
	
	@objc private func algorithmButtonPressed() {
		currentAlgorithm = currentAlgorithm.next()
		algorithmButton.setTitle(currentAlgorithm.description, for: .normal)
		let prevCenter = algorithmButton.center
		algorithmButton.sizeToFit()
		algorithmButton.center = prevCenter
		
		self.teacherDelegate?.newAlgorithmTapped(algorithm: currentAlgorithm)
	}
	
	@objc private func speedButtonPressed() {
		currentSpeed = currentSpeed.next()
		speedButton.setTitle(currentSpeed.description, for: .normal)
		let prevCenter = speedButton.center
		speedButton.sizeToFit()
		speedButton.center = prevCenter
	}
	
	@objc private func randomiseButtonPressed() {
		// disable all buttons until sorting completes
		allButtons.forEach { $0.isEnabled = false }
		
		self.sortDelegate?.randomisePositions()
		self.teacherDelegate?.randomisePositions()
	}
	
	@objc private func sortButtonPressed() {
		// disable all buttons until sorting completes
		allButtons.forEach { $0.isEnabled = false }
		
		self.sortDelegate?.sort(withAlgorithm: currentAlgorithm, trait: currentTrait, speed: currentSpeed)
		self.teacherDelegate?.sort(withAlgorithm: currentAlgorithm, trait: currentTrait, speed: currentSpeed)
	}
	
	// MARK: EmojiSortViewDelegate
	
	public func sortingComplete() {
		allButtons.forEach { $0.isEnabled = true }
	}
	
	private var showcasedElement = false
	
	public func showcaseBegan() {
		showcasedElement = true
		allButtons.forEach { $0.isEnabled = false }
	}
	
	public func showcaseEnded() {
		showcasedElement = false
		allButtons.forEach { $0.isEnabled = true }
	}
	
	// MARK: TeacherViewDelegate
	
	public func interactionReady(fadeDuration:TimeInterval) {
		UIView.animate(withDuration: fadeDuration, animations: {
			self.effectView.effect = nil
		}) { (completed) in
			self.effectView.removeFromSuperview()
		}
	}
	
	
}
