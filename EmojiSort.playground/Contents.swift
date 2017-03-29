/// EmojiSort - a fun, interactive introduction to sorting algorithms.
/// by Bradley Mackey

// ITS GOOD BECAUSE ITS ALSO REVISION ;)

// before it begins have a little introduction where the emoji teacher BRIEFLY explains why sorting algorithms are so important and a brief introduction to running times
// Premise: - A demo of lots of sorting algorithms, applied to a set of a few (15 ish) emojis.
//			- User can choose what trait and sorting algoritm to use
//			- The emojis will have their order randomised and then will be sorted (animated, a sorting arm picks each one up and drops it in a new position) (UIKIT DYNAMICS, pivoting on the fingers of the sorting arm)
//			- LOTS OF OTHER UNNECCARY ANIMATIONS TO MAKE IT LOOK SUPER FANCY (spritekit background maybe?)

// GIVE AN EXPLAINATION OF HOW RECURSIVE ALGORITHMS FUNCTION DIFFERENTLY TO ITERATIVE (MAYBE GIVE A VISUALISATION OF THE CODE THAT IS ACTUALLY BEING RUN AND AN EXPLAINATION TO THE USER)


// *** CLASSES/STRUCTS ***:
// EmojiSortScene: UIVIEW <Lays out everything and performs all the animation needed> [EVERYTHING IS CONTAINED WITHIN THE SORTING SCENE]
// Sorter <THE BRAIN: Does the actual sorting of the emojis> (bubblesort, insertionsort, selectionsort, mergesort, quicksort, stupidsort [stop after a few steps and explain why its bad])
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

var emojis = Emoji.getEmojisFrom(plist: "EmojiStats")


let teacher = EmojiTeacher()
//let scene = MainView(emojiToSort: emojis, emojiTeacher: teacher)

let r = CGRect(x: 0, y: 0, width: 560, height: 200)

let s2 = EmojiSortView(frame: r, emojis: emojis)


PlaygroundPage.current.liveView = s2



let s = "jkkkfg"
