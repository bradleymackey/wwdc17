import Foundation
import UIKit


/// This is the object that contains all the Emojis while we are sorting them, that handles ordering, splitting, joining, holding etc. it's how we know what is where at what time and basically manages all the sorting!!!
/// - note: this class handles all of its own animations
public final class EmojiSortView: UIView {
	
	// MARK: Properties
	
	/// the standard positions where each element should rest
	private let elementFixedPositions:[CGPoint]
	
	/// the postitons and emojis that currently correspond to that position
	private var emojis:[Int:Emoji]
	
	// only need at most 2 sorting arms, if we need to move more than 2 elements at once, we just slide them without the arm (this is only the case when we slide all the elements back from the joining area)
	private var sortingArm1 = SortingArm(grabSpeed: 0.2)
	private var sortingArm2 = SortingArm(grabSpeed: 0.2)
	
	/// an array form of the emoji dict
	private var emojiArray:[Emoji] {
		var emojisArray = [Emoji]()
		for index in emojis.keys.sorted() {
			emojisArray.append(emojis[index]!)
		}
		return emojisArray
	}
	
	private var heldElement:(emoji:Emoji,originIndex:Int)?
	
	private var pivotElement:(emoji:Emoji,originIndex:Int)?
	
	private var holdingPosition:CGPoint {
		return CGPoint(x: self.center.x, y: 20)
	}
	
	
	// MARK: Init
	
	public init(frame:CGRect,emojis:[Emoji]) {
		var positions = [CGPoint]()
		var indexToEmoji = [Int:Emoji]()
		for i in 0..<emojis.count {
			// set all the intial positions
			let pos = CGPoint(x: CGFloat(i+1)*(frame.width/CGFloat(emojis.count+1)), y: 3*frame.height/4)
			positions.append(pos)
			indexToEmoji[i] = emojis[i]
		}
		self.emojis = indexToEmoji
		self.elementFixedPositions = positions
		
		super.init(frame: frame)
		
		self.backgroundColor = .white
		
		setupInitialPositions()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Setup Methods
	
	private func setupInitialPositions() {
		for i in 0..<emojis.count {
			guard let e = emojis[i] else { fatalError("emojis not properly inserted into sorting view") }
			e.center = elementFixedPositions[i]
			self.addSubview(e)
		}
		
		sortingArm1.targetLocation = CGPoint(x: 15, y: 15)
		sortingArm2.targetLocation = CGPoint(x: self.frame.width-15, y: 15)
		self.addSubview(sortingArm1)
		self.addSubview(sortingArm2)
		
		performSortAnimation(for: .mergeSort, trait: .humour, stepTime: 1)
	}
	
	// MARK: Sorting Interface Methods
	
	private var nextStepToPerform = 0
	
	public func performSortAnimation(for algorithm:Sorter.Algorithm, trait:Emoji.Trait,stepTime:TimeInterval) {
		guard let steps = Sorter.sort(objects: emojiArray, with: trait, using: algorithm) else { fatalError() }
		self.performedTimeredAnimation(for: steps, stepTime: stepTime)
	}
	
	public func randomiseEmojiPositions() {
		let steps = Sorter.randomisePositions(objects: emojiArray)
		self.performedTimeredAnimation(for: steps, stepTime: 0.3)
	}
	
	/// - note: 1/3 of the time for claw to move into position, 2/3 to actually move the emoji
	private func performedTimeredAnimation(for steps:[AlgorithmStep], stepTime: TimeInterval) {
		self.nextStepToPerform = 0
		Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { [steps] (timer) in
			defer { self.nextStepToPerform += 1 }
			guard self.nextStepToPerform < steps.count else {
				timer.invalidate()
				self.repairEmojiIndicies()
				return
			}
			self.perform(step: steps[self.nextStepToPerform], time:timer.timeInterval)
		}
	}
	
	// MARK: Step Analysis
	
	private func perform(step: AlgorithmStep, time:TimeInterval) {
		switch step.type {
		case .highlight:
			performHighlight(for: step, time:time)
		case .moveAfter:
			performMoveAfter(for: step, time:time)
		case .moveBefore:
			performMoveBefore(for: step, time:time)
		case .moveToJoiningArea:
			performMoveToJoiningArea(for: step, time:time)
		case .mergeComplete:
			performMergeCompletedForJoiningArea(time:time)
		case .swap:
			performSwap(for: step, time:time)
		case .split:
			performSplit(for: step, time:time)
		case .hold:
			performHold(for: step, time:time)
		case .unhold:
			performUnhold(time:time)
		case .match:
			performMatch(for: step, time:time)
		case .selectPivot:
			selectPivot(for: step, time:time)
		case .dropPivot:
			dropPivot(time:time)
		}
	}
	
	
	// MARK: Performing Steps
	
	private func performHighlight(for step:AlgorithmStep, time:TimeInterval) {
		
	}
	
	/// the indicies of the elements in the joining area's cooridinates
	private var inJoiningArea = [Int:Emoji]()
	/// the indicies freed up in the original row because some elements have moved to the joining area.
	private var indiciesFree = [Int]() {
		didSet {
			print(indiciesFree)
		}
	}

	/// - note: used only in the context of quickSort
	private func performMoveAfter(for step:AlgorithmStep, time:TimeInterval) {
		
	}
	
	/// - note: used only in the context of quickSort
	private func performMoveBefore(for step:AlgorithmStep, time:TimeInterval) {
		
	}
	
	private func performMoveToJoiningArea(for step:AlgorithmStep, time:TimeInterval) {
		let indexToMove = step.mainIndex!
		let newPositionInJoiningArea = step.extraIndex!
		indiciesFree.append(indexToMove)
		inJoiningArea[newPositionInJoiningArea] = emojis[indexToMove]!
		let path = moveToJoiningAreaPath(fromMain: indexToMove, toHolding: newPositionInJoiningArea)
		print("move emoji at \(indexToMove)")
		move(emoji: emojis[indexToMove]!, alongPath: path.path, endPoint:path.endPoint, time: time)
	}
	
	private func performMergeCompletedForJoiningArea(time:TimeInterval) {
		// 'rekeyify' emojis in the joining area so that they will remain in their new order
		// this uses the existing keys and just reassigns them to keep the new sorted order
		let sortedFree = indiciesFree.sorted()
		var currentIndex = 0
		for key in inJoiningArea.keys.sorted() {
			let emoji = inJoiningArea[key]!
			emojis[sortedFree[currentIndex]] = emoji
			currentIndex += 1
		}
		currentIndex = 0
		for i in sortedFree {
			let e = emojis[i]!
			let path = moveBackPath(fromCurrentPosition: e.center, toIndex: i)
			move(emoji: e, alongPath: path.path, endPoint: path.endPoint, time: time)
			print("move back!")
		}
		indiciesFree = []
		inJoiningArea = [:]
	}
	
	private func performSwap(for step:AlgorithmStep, time:TimeInterval) {
		let index1 = step.mainIndex!
		let index2 = step.extraIndex!
		let firstEmoji = emojis[index1]!
		let secondEmoji = emojis[index2]!
		let path1 = carryPath(from: index1, to: index2, extraHigh: true)
		move(emoji: firstEmoji, alongPath: path1.path, endPoint: path1.endPoint, time: time)
		let path2 = carryPath(from: index2, to: index1, extraHigh: false)
		move(emoji: secondEmoji, alongPath: path2.path, endPoint: path2.endPoint, time: time)
		
		emojis[index2] = firstEmoji
		emojis[index1] = secondEmoji
	}
	
	private func performSplit(for step:AlgorithmStep, time:TimeInterval) {
		
	}
	
	private func performHold(for step:AlgorithmStep, time:TimeInterval) {
		let index = step.mainIndex!
		let emoji = emojis[index]!
		heldElement = (emoji,index)
		let path = moveToHoldPositionPath(from: index)
		move(emoji: emoji, alongPath: path.path, endPoint: path.endPoint, time: time)
	}
	
	private func performUnhold(time:TimeInterval) {
		let path = returnFromHoldPositionPath()
		move(emoji: heldElement!.emoji, alongPath: path, endPoint: elementFixedPositions[heldElement!.originIndex], time: time)
	}
	
	private func performMatch(for step:AlgorithmStep, time:TimeInterval) {
		
	}
	
	private func selectPivot(for step:AlgorithmStep, time:TimeInterval) {
		let pivotIndex = step.mainIndex!
		let pivotEmoji = emojis[pivotIndex]!
		pivotElement = (pivotEmoji,pivotIndex)
		let path = moveToJoiningAreaPath(fromMain: pivotIndex, toHolding: pivotIndex)
		move(emoji: pivotEmoji, alongPath: path.path, endPoint: path.endPoint, time: time)
	}
	
	private func dropPivot(time:TimeInterval) {
		
	}
	
	
	
	
	
	// MARK: Step Paths
	
	/// gets a bezier path for the emojis to follow, when they are the main emoji being moved horizontally along the list
	private func carryPath(from index1: Int, to index2: Int, extraHigh:Bool) -> (path:UIBezierPath,endPoint:CGPoint) {
		let point1 = elementFixedPositions[index1]
		let point2 = elementFixedPositions[index2]
		let controlPoint = CGPoint(x: (point1.x+point2.x)/2, y: extraHigh ? self.frame.height/3 : self.frame.height/1.8)
		let path = UIBezierPath()
		path.move(to: point1)
		path.addQuadCurve(to: point2, controlPoint: controlPoint)
		return (path,point2)
	}
	
	/// gets a bezier path for the emojis to follow, when an emoji simply needs to shift to make room for another emoji
//	private func shiftPath(from index1: Int, to index2: Int) -> UIBezierPath {
//		let point1 = elementFixedPositions[index1]
//		let point2 = elementFixedPositions[index2]
//		let path = UIBezierPath()
//		path.move(to: point1)
//		path.addLine(to: point2)
//		return path
//	}
	
	private func moveToHoldPositionPath(from index:Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let path = UIBezierPath()
		path.move(to: elementFixedPositions[index])
		path.addQuadCurve(to: holdingPosition, controlPoint: controlPointForHoldingPosition(for: index))
		return (path,holdingPosition)
	}
	
	private func returnFromHoldPositionPath() -> UIBezierPath {
		let backToPosition = elementFixedPositions[heldElement!.originIndex]
		let path = UIBezierPath()
		path.move(to: holdingPosition)
		path.addQuadCurve(to: backToPosition, controlPoint: controlPointForHoldingPosition(for: heldElement!.originIndex))
		return path
	}
	
	private func controlPointForHoldingPosition(for index:Int) -> CGPoint {
		return index < emojiArray.count/2 ? CGPoint(x: self.frame.width/4, y: self.frame.height/4) : CGPoint(x: 3*self.frame.width/4, y: self.frame.height/4)
	}
	
	private func moveToJoiningAreaPath(fromMain index1:Int, toHolding index2:Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let startingPosition = elementFixedPositions[index1]
		let endingPosition = CGPoint(x: elementFixedPositions[index2].x, y: self.frame.height/2)
		let path = UIBezierPath()
		path.move(to: startingPosition)
		path.addLine(to: endingPosition)
		return (path,endingPosition)
	}
	
	private func moveBackPath(fromCurrentPosition position:CGPoint, toIndex index:Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let endingPosition = elementFixedPositions[index]
		let path = UIBezierPath()
		path.move(to: position)
		path.addLine(to: endingPosition)
		return (path,endingPosition)
	}
	
	// MARK: Animation
	
	private func move(emoji:Emoji, alongPath path:UIBezierPath, endPoint:CGPoint, time:TimeInterval) {
		// code adapted from: http://stackoverflow.com/questions/12885226/drag-uiview-along-bezier-path
		DispatchQueue.main.async {

			let pathAnimation = CAKeyframeAnimation(keyPath: "position")
			pathAnimation.duration = time*0.6666 // 2/3 for moving, 1/3 for moving claw
			pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			pathAnimation.path = path.cgPath
			pathAnimation.isRemovedOnCompletion = false
			pathAnimation.fillMode = kCAFillModeForwards
			emoji.center = endPoint
			emoji.layer.add(pathAnimation, forKey: "pathAnimation")

		}
	}
	
	private func highlight(emoji:Emoji, intensitity:AlgorithmStep.StepType.HighlightIntensity, time:TimeInterval) {
		DispatchQueue.main.async {
			let animation = CABasicAnimation(keyPath: "transform.scale")
			animation.duration = time/2 // how long the animation will take
			animation.repeatCount = 1
			animation.autoreverses = true // so it auto returns to 0 offset
			animation.fromValue = 1
			animation.toValue = intensitity == .small ? 1.08 : 1.2
			emoji.layer.add(animation, forKey: "transform.scale")
		}
	}
	
	
	
	
	// MARK: Maintenance
	
	/// In the case of quickSort, the indices of the elements can get shifted during sorting, this restores all the indcies to consecutive values starting from 0, while maintaining the order.
	private func repairEmojiIndicies() {
		let starting = emojis
		var badIndicies = emojis.keys.sorted()
		var completed = [Int:Emoji]()
		var i = 0
		for index in badIndicies {
			defer { i += 1 }
			let e = starting[index]
			completed[i] = e
		}
		self.emojis = completed
	}
	
	
}
