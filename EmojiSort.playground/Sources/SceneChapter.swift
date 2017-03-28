//
//  SceneStage.swift
//
//
//  Created by Bradley Mackey on 20/03/2017.
//
//

//	This file contains the different stages and how they progress of the introduction to the Playground.

import Foundation
import UIKit

public enum SceneChapter: Int {
	/// Emoji teacher says hello.
	case welcome = 0
	/// Emoji teacher takes us through some applications and examples of sorting algorithms.
	case slideshow = 1
	/// Emoji teacher introduces us to the emojis that we will be sorting.
	case emojiIntroduction = 2
	/// The scene is now fully interactive and user can try out the different sorting alogorithms.
	case userInteraction = 3
	
	public func nextChapter() -> SceneChapter? {
		return SceneChapter(rawValue: self.rawValue+1)
	}
}
