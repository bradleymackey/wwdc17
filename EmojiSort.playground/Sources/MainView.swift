//
//  EmojiSortScene.swift
//  
//
//  Created by Bradley Mackey on 14/03/2017.
//
//

import Foundation
import UIKit

/// # MainView
/// The scene where everything is rendered.
public final class MainView: UIView {

	
	// MARK: Behaviour Properties
	
	public static let titleFlipFlopInterval:TimeInterval = 3
	
	// MARK: Properties
	
	public var emoji:[Emoji]
	public let emojiTeacher:EmojiTeacher
	
	private var teacherTouched = false
	
	private var snoringTimer:Timer?
	
	private var animator: UIDynamicAnimator?
	private var snapBehavior: UISnapBehavior?
	
	private let collisionBehavior: UICollisionBehavior
	private let gravityBehavior: UIGravityBehavior
	private let zLabelBehavior: UIDynamicItemBehavior
	
	private var chart = BarChartView(frame: CGRect(x:0,y:0,width:300,height:100), collectionViewLayout: UICollectionViewFlowLayout())
	
	// MARK: Init
	
	public init(emojiToSort emoji:[Emoji], emojiTeacher:EmojiTeacher) {
		
		self.emoji = emoji
		self.emojiTeacher = emojiTeacher
		
		collisionBehavior = UICollisionBehavior(items: [])
		collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		gravityBehavior = UIGravityBehavior(items: [])
		zLabelBehavior = UIDynamicItemBehavior(items: [])
		zLabelBehavior.elasticity = 0.4
		
		let frame = CGRect(x: 0, y: 0, width: 700, height: 480)
		super.init(frame: frame)
		
		animator = UIDynamicAnimator(referenceView: self)
		animator?.addBehavior(collisionBehavior)
		animator?.addBehavior(gravityBehavior)
		animator?.addBehavior(zLabelBehavior)
		
		self.addSubview(chart)
		self.chart.center = self.center
		self.chart.reloadData()
	
		setupScene()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	private func setupScene() {
		
		self.backgroundColor = .white
		
		self.emojiTeacher.center = self.center
		self.addSubview(emojiTeacher)
		
		
		self.teacherStartSnoring()
		
		
		
		let claw = SortingArm(grabSpeed: 0.04)
		claw.center = self.center
		print("target loc then: \(claw.center)")
		self.addSubview(claw)
		Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { (timer) in
			claw.clawState = self.state.next()
			self.state = self.state.next()
			DispatchQueue.main.async {
				UIView.animate(withDuration: 2, animations: { 
					claw.targetLocation = self.center
					print("claw target now: \(claw.center)")
				})
			}
		}
	}
	
	var state:SortingArm.ClawState = .open
	
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
	
	private func teacherStartSnoring() {
		snoringTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [unowned self] (timer) in
			let snoreLabel = UILabel(frame: .zero)
			snoreLabel.textAlignment = .center
			snoreLabel.center = CGPoint(x: self.emojiTeacher.center.x, y: self.emojiTeacher.center.y-10)
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
	
	// MARK: Touches interaction
	
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		// determining what the user touched
		if emojiTeacher.frame.contains(location) {
			// stop the teacher from snoring
			snoringTimer?.invalidate()
			//instructionsTitle.stopFlipFlop()
			emojiTeacher.currentEmotion = .shocked
			//instructionsTitle.animateTitle(to: .userInteractionPrompt, position: instructionsTitle.center, text: "")
			emojiTeacher.bounce(1, completion: nil)
			teacherTouched = true
			
			
			
			
		}
		
		chart.items.sort()
		
		
		self.chart.performBatchUpdates({
			self.chart.reloadSections([0])
		}, completion: nil)
	}
	
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		if emojiTeacher.frame.contains(location) && teacherTouched {
			teacherTouched = false
			emojiTeacher.currentEmotion = .unimpressed
			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
				DispatchQueue.main.async {
					self.emojiTeacher.shake {
						self.emojiTeacher.currentEmotion = .talking
					}
				}
			}
		}
	}
	
	public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		if !emojiTeacher.frame.contains(location) && teacherTouched {
			teacherTouched = false
			emojiTeacher.currentEmotion = .unimpressed
			Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
				DispatchQueue.main.async {
					self.emojiTeacher.shake {
						self.emojiTeacher.currentEmotion = .talking
						let pos = CGPoint(x: self.emojiTeacher.center.x, y: self.emojiTeacher.center.y+self.frame.height/8)
					}
				}
			}
		}
	}
	
	/// Depending on the current chapter and stage we are at, this function will respond accordingly and either progress the scene to the next stage or the next chapter.
	private func determineTouchAction() {
		
	}
	
	
	
	
	// BAR CHART;
	
	
	
	
	

}


