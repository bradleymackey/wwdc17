import Foundation
import UIKit

public protocol TitleLabelDelegate: class {
	func titleLabelCollisionBoundsNeedUpdate(for label:TitleLabel)
}

public final class TitleLabel: UILabel {
	
	// MARK: Enums
	
	public enum TitleStyle {
		case title
		case userInteractionPrompt
		case teacherTalk
	}
	
	// MARK: Properties
	
	public weak var delegate:TitleLabelDelegate?
	
	public var currentStyle = TitleStyle.title
	
	private var flipFlopTimer:Timer?
	private var flipFlopFirstTitle:(style:TitleStyle,title:String)?
	private var titleIsInitialInstruction = false
	
	// MARK: Init
	
	public init(position:CGPoint,initialText:String) {
		super.init(frame: .zero)
		applyAttributes(for: currentStyle)()
		self.text = initialText
		self.textAlignment = .center
		self.sizeToFit()
		self.center = position
		self.numberOfLines = 1 // initally just one line
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	/// Set the title of the label with a nice animation
	public func animateTitle(to style:TitleStyle, position: CGPoint, text:String) {
		currentStyle = style
		UIView.transition(with: self, duration: 0.2, options: [.transitionCrossDissolve], animations: {
			self.text = text
			self.applyAttributes(for: style)()
			self.sizeToFit()
			self.center = position
			self.delegate?.titleLabelCollisionBoundsNeedUpdate(for: self)
		}, completion: nil)
	}
	
	
	private func applyAttributes(for style:TitleStyle) -> (()->Void) {
		switch style {
		case .title:
			return {
				self.font = UIFont.boldSystemFont(ofSize: 48)
				self.textColor = .black
			}
		case .userInteractionPrompt:
			return {
				self.font = UIFont.boldSystemFont(ofSize: 20)
				self.textColor = .lightGray
			}
		case .teacherTalk:
			return {
				self.font = UIFont.systemFont(ofSize: 25)
				self.textColor = .darkGray
			}
		}
	}
	
	/// 'Flip flop' between 2 different titles with a nice animation.
	public func startFlipFlop(duration:TimeInterval,position:CGPoint,firstStyle:TitleLabel.TitleStyle,firstText:String,secondStyle:TitleLabel.TitleStyle,secondText:String) {
		// set the firstTitle property
		flipFlopFirstTitle = (firstStyle,firstText)
		// immediatly set the title to the first title
		self.animateTitle(to: firstStyle, position: position, text: firstText)
		// begin the flip flop
		flipFlopTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [unowned self] (timer) in
			if self.titleIsInitialInstruction {
				self.animateTitle(to: firstStyle, position: position, text: firstText)
			} else {
				self.animateTitle(to: secondStyle, position: position, text: secondText)
			}
			self.titleIsInitialInstruction = !self.titleIsInitialInstruction
		}
	}
	
	/// Stop the changing of titles and return to the first title.
	public func stopFlipFlop() {
		guard let timer = flipFlopTimer else { return }
		timer.invalidate()
		guard let firstTitleInfo = flipFlopFirstTitle else { return }
		self.animateTitle(to: firstTitleInfo.style, position: self.center, text: firstTitleInfo.title)
	}
	
}
