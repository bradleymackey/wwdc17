import Foundation
import UIKit


/// This is the object that contains all the Emojis while we are sorting them, that handles ordering, splitting, joining, holding etc. it's how we know what is where at what time and basically manages all the sorting!!!
/// - note: this class handles all of its own animations
public final class EmojiSortView: UIView {
	
	// MARK: Properties
	
	/// the standard positions where each element should rest
	private var elementPositions:[CGPoint]
	
	/// used by merge sort when element groups split
	private enum SplitDirection: CGFloat {
		case left = -2
		case right = 2
	}
	
	/// the postitons and emojis that currently correspond to that position
	private var emojis:[Int:Emoji]
	
	// only need at most 2 sorting arms, if we need to move more than 2 elements at once, we just slide them without the arm (this is only the case when we slide all the elements back from the joining area)
	private var sortingArm1 = SortingArm(grabSpeed: 0.05)
	private var sortingArm2 = SortingArm(grabSpeed: 0.05)
	
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
		return CGPoint(x: self.center.x, y: self.frame.height/4)
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
		self.elementPositions = positions
		
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
			e.center = elementPositions[i]
			self.addSubview(e)
		}
		
		sortingArm1.startingPosition = CGPoint(x: 35, y: 35)
		sortingArm1.center = sortingArm1.startingPosition
		sortingArm2.startingPosition = CGPoint(x: self.frame.width-35, y: 35)
		sortingArm2.center = sortingArm2.startingPosition
		self.addSubview(sortingArm1)
		self.addSubview(sortingArm2)
		
		performSortAnimation(for: .insertionSort, trait: .popularity, stepTime: 1)
	}
	
	// MARK: Sorting Interface Methods
	
	private var nextStepToPerform = 0
	
	public func performSortAnimation(for algorithm:Sorter.Algorithm, trait:Emoji.Trait,stepTime:TimeInterval) {
		guard let steps = Sorter.sort(objects: emojiArray, with: trait, using: algorithm) else { fatalError() }
		for step in steps {
			print(step)
		}
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
				self.grabberReturnHome(grabber: self.sortingArm1)
				self.grabberReturnHome(grabber: self.sortingArm2)
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
		case .slide:
			performSlide(for: step, time:time)
		}
	}
	
	
	// MARK: Performing Steps
	
	private func performHighlight(for step:AlgorithmStep, time:TimeInterval) {
        let indexToHighlight = step.mainIndex!
		let intensity = step.highlightIntensity!
        highlight(emoji: emojis[indexToHighlight]!, intensitity: intensity, time: time)
		moveGrabberAbovePosition(point: emojis[indexToHighlight]!.center.x, isExtra: false, time: time)
        guard let secondIndex = step.extraIndex else { return }
        highlight(emoji: emojis[secondIndex]!, intensitity: intensity, time: time)
		moveGrabberAbovePosition(point: emojis[secondIndex]!.center.x, isExtra: true, time: time)
        guard let thirdIndex = step.extraExtraIndex else { return }
        highlight(emoji: emojis[thirdIndex]!, intensitity: intensity, time: time)
	}
	
	/// the indicies of the elements in the joining area's cooridinates, with emoji in that position
    private var inJoiningArea = [Int:Emoji]() {
        didSet {
            print("in joining area: \(inJoiningArea)")
        }
    }
	/// the indicies freed up in the original row because some elements have moved to the joining area.
	private var indiciesFree = Set<Int>() {
		didSet {
			print("free indicies: \(indiciesFree)")
		}
	}

	/// used for mergeSort when moving to the joining area
	private func performMoveToJoiningArea(for step:AlgorithmStep, time:TimeInterval) {
		let indexToMove = step.mainIndex!
		let newPositionInJoiningArea = step.extraIndex!
		indiciesFree.insert(indexToMove)
		inJoiningArea[newPositionInJoiningArea] = emojis[indexToMove]!
		let path = moveToJoiningAreaPath(fromMain: emojis[indexToMove]!.center, toHolding: newPositionInJoiningArea)
		print("move emoji at \(indexToMove)")
		move(emoji: emojis[indexToMove]!, alongPath: path.path, endPoint:path.endPoint, time: time, useGrabber: true)
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
		for i in sortedFree {
			let e = emojis[i]!
			let path = moveBackPath(fromCurrentPosition: e.center, toIndex: i)
			move(emoji: e, alongPath: path.path, endPoint: path.endPoint, time: time, useGrabber: false)
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
		move(emoji: firstEmoji, alongPath: path1.path, endPoint: path1.endPoint, time: time, useGrabber: true)
		let path2 = carryPath(from: index2, to: index1, extraHigh: false)
		move(emoji: secondEmoji, alongPath: path2.path, endPoint: path2.endPoint, time: time, useGrabber: true, extraGrabber: true)
		
		emojis[index2] = firstEmoji
		emojis[index1] = secondEmoji
	}
	
	private func performSplit(for step:AlgorithmStep, time:TimeInterval) {
//		let leftIndex = step.mainIndex!
//        let rightIndex = step.extraIndex!
//        for i in 0...leftIndex {
//            let emoji = emojis[i]!
//            let path = splitPath(startingPoint: emoji.center, direction: .left)
//			move(emoji: emoji, alongPath: path.path, endPoint: path.endPoint, time: time, useGrabber: false)
//        }
//        for i in rightIndex..<emojis.count {
//            let emoji = emojis[i]!
//            let path = splitPath(startingPoint: emoji.center, direction: .right)
//			move(emoji: emoji, alongPath: path.path, endPoint: path.endPoint, time: time, useGrabber: false)
//        }
	}
	
	private func performHold(for step:AlgorithmStep, time:TimeInterval) {
		let index = step.mainIndex!
		let emoji = emojis[index]!
		heldElement = (emoji,index)
		indiciesFree.insert(index)
		let path = moveToHoldPositionPath(from: index)
		move(emoji: emoji, alongPath: path.path, endPoint: path.endPoint, time: time, useGrabber: true, extraGrabber: true)
	}
	
	/// moves held element to the free space in the list
	private func performUnhold(time:TimeInterval) {
		let path = returnFromHoldPositionPath()
		move(emoji: heldElement!.emoji, alongPath: path.path, endPoint: path.endPoint, time: time, useGrabber: true, extraGrabber: true)
		// cleanup to set the appropaite index for emoji
		emojis[indiciesFree.first!] = heldElement!.emoji
		indiciesFree = []
		heldElement = nil
	}
	
	private func performSlide(for step:AlgorithmStep, time:TimeInterval) {
		let fromPosition = step.mainIndex!
		let toPosition = step.extraIndex!
		let path = slidePath(from: fromPosition, by: toPosition)
		move(emoji: emojis[fromPosition]!, alongPath: path.path, endPoint: path.endPoint, time: time, useGrabber: true)
		emojis[toPosition] = emojis[fromPosition]!
		// set the new free index
		indiciesFree.remove(toPosition)
		indiciesFree.insert(fromPosition)
	}
	
	// MARK: Step Paths
	
	/// gets a bezier path for the emojis to follow, when they are the main emoji being moved horizontally along the list
	private func carryPath(from index1: Int, to index2: Int, extraHigh:Bool) -> (path:UIBezierPath,endPoint:CGPoint) {
		let point1 = elementPositions[index1]
		let point2 = elementPositions[index2]
		let controlPoint = CGPoint(x: (point1.x+point2.x)/2, y: extraHigh ? self.frame.height/3 : self.frame.height/1.8)
		let path = UIBezierPath()
		path.move(to: point1)
		path.addQuadCurve(to: point2, controlPoint: controlPoint)
		return (path,point2)
	}
	
	/// gets a bezier path for the emojis to follow, when an emoji simply needs to shift to make room for another emoji
	private func slidePath(from index1: Int, by index2: Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let point1 = elementPositions[index1]
		let point2 = elementPositions[index2]
		let path = UIBezierPath()
		path.move(to: point1)
		path.addLine(to: point2)
		return (path, point2)
	}
	
	private func quickSortSlidePath(from index1: Int, by index2: Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let point1 = elementPositions[index1]
		let point2 = elementPositions[index2]
		let path = UIBezierPath()
		path.move(to: point1)
		path.addLine(to: point2)
		return (path, point2)
	}
    
    private func splitPath(startingPoint: CGPoint, direction:SplitDirection) -> (path:UIBezierPath,endPoint:CGPoint) {
        let endPoint = CGPoint(x: startingPoint.x+direction.rawValue, y: startingPoint.y)
        let path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: endPoint)
        return (path,endPoint)
    }
	
	private func moveToHoldPositionPath(from index:Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let path = UIBezierPath()
		path.move(to: elementPositions[index])
		path.addQuadCurve(to: holdingPosition, controlPoint: controlPointForHoldingPosition(for: index))
		return (path,holdingPosition)
	}
	
	private func returnFromHoldPositionPath() -> (path:UIBezierPath,endPoint:CGPoint) {
		let backToPosition = elementPositions[indiciesFree.first!]
		let path = UIBezierPath()
		path.move(to: holdingPosition)
		path.addLine(to: backToPosition)
		return (path,backToPosition)
	}
	
	private func controlPointForHoldingPosition(for index:Int) -> CGPoint {
		return index < emojiArray.count/2 ? CGPoint(x: self.frame.width/4, y: self.frame.height/4) : CGPoint(x: 3*self.frame.width/4, y: self.frame.height/4)
	}
	
	private func moveToJoiningAreaPath(fromMain startingPosition:CGPoint, toHolding index2:Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let endingPosition = CGPoint(x: elementPositions[index2].x, y: self.frame.height/2)
		let path = UIBezierPath()
		path.move(to: startingPosition)
		path.addLine(to: endingPosition)
		return (path,endingPosition)
	}
	
	private func moveBackPath(fromCurrentPosition position:CGPoint, toIndex index:Int) -> (path:UIBezierPath,endPoint:CGPoint) {
		let endingPosition = elementPositions[index]
		let path = UIBezierPath()
		path.move(to: position)
		path.addLine(to: endingPosition)
		return (path,endingPosition)
	}
	
	// MARK: Animation
	
	private func move(emoji:Emoji, alongPath path:UIBezierPath, endPoint:CGPoint, time:TimeInterval, useGrabber:Bool, extraGrabber:Bool=false) {
		// code adapted from: http://stackoverflow.com/questions/12885226/drag-uiview-along-bezier-path
		DispatchQueue.main.async {
			
			let grabber = extraGrabber ? self.sortingArm2 : self.sortingArm1
			
	
			if useGrabber {
				CATransaction.begin()
				CATransaction.setCompletionBlock {
					grabber.clawState = .grabbed
					DispatchQueue.main.async {
						self.moveEmoji(emoji: emoji, path: path, endPoint: endPoint, time: time, useGrabber: useGrabber, extraGrabber: extraGrabber)
					}
				}
				let pathAnimation = CABasicAnimation(keyPath: "position")
				pathAnimation.duration = time*0.15
				pathAnimation.fromValue = NSValue(cgPoint: grabber.center)
				pathAnimation.toValue = NSValue(cgPoint: CGPoint(x: emoji.center.x, y: emoji.center.y-11))
				pathAnimation.isRemovedOnCompletion = false
				pathAnimation.fillMode = kCAFillModeForwards
				grabber.center =  CGPoint(x: emoji.center.x, y: emoji.center.y-11)
				grabber.layer.add(pathAnimation, forKey: "moveToEmoji")
				CATransaction.commit()
			} else {
				DispatchQueue.main.async {
					self.moveEmoji(emoji: emoji, path: path, endPoint: endPoint, time: time, useGrabber: useGrabber, extraGrabber: extraGrabber)
				}
			}
			
		}
	}
	
	private func moveEmoji(emoji: Emoji, path:UIBezierPath, endPoint:CGPoint, time:TimeInterval, useGrabber:Bool, extraGrabber:Bool=false) {
		
		let grabber = extraGrabber ? self.sortingArm2 : self.sortingArm1
		
		CATransaction.begin()
		CATransaction.setCompletionBlock {
			grabber.clawState = .open
		}
		let pathAnimation = CAKeyframeAnimation(keyPath: "position")
		pathAnimation.duration = time*0.5
		pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		pathAnimation.path = path.cgPath
		pathAnimation.isRemovedOnCompletion = false
		pathAnimation.fillMode = kCAFillModeForwards
		emoji.center = endPoint
		emoji.layer.add(pathAnimation, forKey: "pathAnimation")
		
		if useGrabber {
			grabber.center = endPoint
			grabber.clawState = .grabbed
			grabber.layer.add(pathAnimation, forKey: "pa")
		}
		
		CATransaction.commit()
		
		print("claw post: \(grabber.targetLocation)")
	}
	
	private func moveGrabberAbovePosition(point:CGFloat,isExtra:Bool,time:TimeInterval) {
		DispatchQueue.main.async {
			
			let grabber = isExtra ? self.sortingArm2 : self.sortingArm1
			CATransaction.begin()
			let pathAnimation = CABasicAnimation(keyPath: "position")
			pathAnimation.duration = time*0.15
			pathAnimation.fromValue = NSValue(cgPoint: grabber.center)
			pathAnimation.toValue = NSValue(cgPoint: CGPoint(x: point, y: self.frame.height/2))
			pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			pathAnimation.isRemovedOnCompletion = false
			pathAnimation.fillMode = kCAFillModeForwards
			grabber.center =  CGPoint(x:point, y: self.frame.height/2)
			grabber.layer.add(pathAnimation, forKey: "moveAboveEmoji")
			CATransaction.commit()
		}
	}
	
	private func grabberReturnHome(grabber:SortingArm) {
		DispatchQueue.main.async {
			CATransaction.begin()
			let pathAnimation = CABasicAnimation(keyPath: "position")
			pathAnimation.duration = 2
			pathAnimation.fromValue = NSValue(cgPoint: grabber.center)
			pathAnimation.toValue = NSValue(cgPoint: grabber.startingPosition)
			pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			pathAnimation.isRemovedOnCompletion = false
			pathAnimation.fillMode = kCAFillModeForwards
			grabber.center =  grabber.startingPosition
			grabber.layer.add(pathAnimation, forKey: "grabberGoHome")
			CATransaction.commit()
		}
	}
	
	private func highlight(emoji:Emoji, intensitity:AlgorithmStep.StepType.HighlightIntensity, time:TimeInterval) {
		DispatchQueue.main.async {
			let animation = CABasicAnimation(keyPath: "transform.scale")
			animation.duration = time/8 // how long the animation will take
			animation.repeatCount = 1
			animation.autoreverses = true // so it auto returns to 0 offset
			animation.fromValue = 1
			animation.toValue = intensitity == .small ? 1.3 : 1.8
			emoji.layer.add(animation, forKey: "transform.scale")
		}
	}
	
}
