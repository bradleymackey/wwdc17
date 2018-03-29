/// EmojiSort - a fun, interactive introduction to sorting algorithms.
/// by Bradley Mackey

import UIKit
import PlaygroundSupport

// get the emojis that we are going to sort
var emojis = Emoji.getEmojisFrom(plist: "EmojiStats")

// create a teacher
let teacher = EmojiTeacher()

// create the scene
let scene = ContainerView(emojiToSort: emojis, teacher: teacher)

// present the scene
PlaygroundPage.current.liveView = scene
