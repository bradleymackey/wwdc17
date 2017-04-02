/// EmojiSort - a fun, interactive introduction to sorting algorithms.
/// by Bradley Mackey

// ITS GOOD BECAUSE ITS ALSO REVISION ;)

// *** CLASSES/STRUCTS ***:
// EmojiSortScene: UIVIEW <Lays out everything and performs all the animation needed> [EVERYTHING IS CONTAINED WITHIN THE SORTING SCENE]
// Sorter <THE BRAIN: Does the actual sorting of the emojis> (bubblesort, insertionsort, selectionsort, mergesort, quicksort, stupidsort [stop after as few steps and explain why its bad])
// SortStep <A struct containing a move>
// Emoji: UILabel, Sortable (prot), Hashable (prot) <traits: funnyness, >
// EmojiTrait ENUM
// EmojiTeacher: UILabel, <PROVIDES HELPFUL KNOWLEDGE ON ALL THE ALGORITHMS>
// SpeechBubble: UILabel <Produced by the emoji techer when they have something to say>
// SortingArm: UIView <the moving arm that 'picks up' emojis and moves them about> <has functions to 'pinch(emoji:SortableEmoji)' 'unpinchEmoji() -> SortableEmoji'>

// TODO: *** FOR 23/03 ***
// - 'Hard stuff' pretty much done.
// - Get user interface working (don't worry so much about what the emoji teacher is actually saying at this point).
// - Extra animations (gameplay kit? - other little baby emojis following the emoji teacher)
// - Maybe have a spritekit background (then the interface would look much more fancy).

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



let s = "fjfjg"
