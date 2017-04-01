import Foundation
import UIKit


public final class ContainerView: UIView {
	
	
	private var teacherView:TeacherView
	private var optionView:OptionView
	private var sortingView:EmojiSortView
	
	
	public init(frame: CGRect, emojiToSort: [Emoji], teacher: EmojiTeacher) {
		
		let teachRect = CGRect(x: 0, y: 0, width: frame.width/3, height: frame.height/2)
		teacherView = TeacherView(frame: teachRect, teacher: teacher)
		let optionRect = CGRect(x: frame.width/3, y: 0, width: 2*frame.width/3, height: frame.height/2)
		optionView = OptionView(frame: optionRect)
		let sortingRect = CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2)
		sortingView = EmojiSortView(frame: sortingRect, emojis: emojiToSort.shuffled())
		
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

