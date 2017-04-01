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
	
	
	
}

