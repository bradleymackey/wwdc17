import Foundation
import UIKit

public final class TitleLabel: UILabel {
	
	// MARK: Enums
	
	public enum TitleStyle {
		/// when the 'narrator' is talking - that is, the person telling us to wake up the emoji teacher etc.
		case narratorTalk
		/// the text style that displays when we need to take action on the emoji teacher.
		case userInteractionPrompt
		/// text style used when the emoji teacher is talking
		case teacherTalk
		/// text style used on the `EmojiSortView`, helping the user by telling them what to do.
		case sortHelp
	}
	
	// MARK: Properties
	
	public var currentStyle = TitleStyle.narratorTalk
	
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
		}, completion: nil)
	}
	
	
	private func applyAttributes(for style:TitleStyle) -> (()->Void) {
		switch style {
		case .narratorTalk:
			return {
				self.font = UIFont.boldSystemFont(ofSize: 32)
				self.textColor = .white
			}
		case .userInteractionPrompt:
			return {
				self.font = UIFont.boldSystemFont(ofSize: 20)
				self.textColor = .white
			}
		case .teacherTalk:
			return {
				self.font = UIFont.systemFont(ofSize: 20)
				self.textColor = .white
			}
		case .sortHelp:
			return {
				self.font = UIFont.boldSystemFont(ofSize: 12)
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
