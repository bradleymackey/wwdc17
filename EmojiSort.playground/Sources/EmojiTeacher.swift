import Foundation
import UIKit

public final class EmojiTeacher: UILabel {
	
	// MARK: Enums
	
	public enum Emotion: String {
		case talking = "😄😁"
		case happy = "😄" // resting happy face
		case happyTalk = "😁" // chatting face
		case confused = "😕" // this is confusing
		case unimpressed = "😒" // unimpressive algorithm
		case shocked = "😮" // shockingly good (or bad)
		case cool = "😎" // this is a cool algorithm
		case love = "😍" // he likes an algorithm
		case sleeping = "😴" // he's sleeping
	}
	
	// MARK: Properties
	
	public var currentEmotion:Emotion = .sleeping {
		didSet {
			stopTalking()
			if currentEmotion == .talking {
				startTalking()
			} else {
				self.text = currentEmotion.rawValue
			}
		}
	}
	
	private var talkingTimer:Timer?
	private var talkingMouthOpen = true
	
	// MARK: Init
	
	public init() {
		super.init(frame: .zero)
		self.font = UIFont.systemFont(ofSize: 35)
		self.text = currentEmotion.rawValue
		self.textAlignment = .center
		self.sizeToFit()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		talkingTimer?.invalidate()
	}
	
	// MARK: Methods
	
	private func startTalking() {
		talkingMouthOpen = true
		let fullTalking = Emotion.talking.rawValue
		let oneOffset = fullTalking.index(fullTalking.startIndex, offsetBy: 1)
		self.text = fullTalking.substring(to: oneOffset)
		talkingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [unowned self, fullTalking, oneOffset] (timer) in
			if self.talkingMouthOpen {
				self.text = fullTalking.substring(from: oneOffset)
			} else {
				self.text = fullTalking.substring(to: oneOffset)
			}
			self.talkingMouthOpen = !self.talkingMouthOpen
		}
	}
	
	private func stopTalking() {
		self.talkingTimer?.invalidate()
		self.talkingMouthOpen = true
	}
	
	
	
	
	
}
