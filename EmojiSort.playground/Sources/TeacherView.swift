import Foundation
import UIKit

/// The view module that contains the emoji teacher and their speech.
public final class TeacherView: UIView, OptionChangeReactable {
	
	
	

	public init(frame:CGRect, teacher:EmojiTeacher) {
		super.init(frame: frame)
	}
	
	
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Delegate
	
	public func sort(withAlgorithm algorithm: Sorter.Algorithm, trait: Emoji.Trait, speed: AlgorithmSpeed) {
		
	}
	
	public func randomisePositions() {
		
	}
	
	public func newTraitTapped(trait: Emoji.Trait) {
		fatalError("don't care about this here")
	}
	
	public func newAlgorithmTapped(algorithm: Sorter.Algorithm) {
		
	}
	
	
}

