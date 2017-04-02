import Foundation
import UIKit


public final class ContainerView: UIView {
	
	// MARK: Properties
	
	private var teacherView:TeacherView
	private var optionView:OptionView
	private var sortingView:EmojiSortView
	
	// MARK: Init
	
	public init(emojiToSort: [Emoji], teacher: EmojiTeacher) {
		
		let frame = CGRect(x: 0, y: 0, width: 600, height: 350)
		
		let teachRect = CGRect(x: 0, y: 0, width: frame.width/2, height: frame.height/2)
		teacherView = TeacherView(frame: teachRect, teacher: teacher)
		let optionRect = CGRect(x: frame.width/2, y: 0, width: frame.width/2, height: frame.height/2)
		optionView = OptionView(frame: optionRect)
		let sortingRect = CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2)
		sortingView = EmojiSortView(frame: sortingRect, emojis: emojiToSort.shuffled())
		
		// set delegates to enable communication between views
		optionView.sortDelegate = sortingView
		optionView.teacherDelegate = teacherView
		
		super.init(frame: frame)
		
		self.addSubview(teacherView)
		self.addSubview(optionView)
		self.addSubview(sortingView)
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}

