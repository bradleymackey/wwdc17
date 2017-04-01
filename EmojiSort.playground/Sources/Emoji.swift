import Foundation
import UIKit

/// # Emoji
/// Represents an emoji to sort that we render in the scene
public final class Emoji: UILabel, TraitSortable {
	
	// MARK: Properties
	
	/// The character of this specific emoji
	public let emojiCharacter:String
	
	/// The traits of each emoji
	/// - note: must be an `Int` between 0 and 99
	public enum Trait: CustomStringConvertible {
		case happiness
		case popularity
		case emotion
		case humour
		case sarcastic
		
		public var description: String {
			switch self {
			case .happiness:
				return "Happiness"
			case .popularity:
				return "Popularity"
			case .emotion:
				return "Emotion"
			case .humour:
				return "Humour"
			case .sarcastic:
				return "Use Sarcastically"
			}
		}
	}
	
	public var traits = [Trait:Int]()
	
	public var name:String
	
	// MARK: Init
	
	public init(emoji:String, name:String, happiness:Int, popularity:Int, emotion:Int, humour:Int, sarcastic:Int) {
		
		// set the emoji
		self.emojiCharacter = emoji
		
		self.name = name
		
		// set its traits
		traits[.happiness] = happiness
		traits[.popularity] = popularity
		traits[.emotion] = emotion
		traits[.humour] = humour
		traits[.sarcastic] = sarcastic
		
		// setup the visible portion
		super.init(frame: .zero)
		self.font = UIFont.systemFont(ofSize: 18)
		self.textAlignment = .center
		self.text = emojiCharacter
		self.sizeToFit()
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	public static func getEmojisFrom(plist filename:String) -> [Emoji] {
		var emojis = [Emoji]()
		guard let path = Bundle.main.path(forResource: filename, ofType: "plist") else { fatalError("Cannot find file.") }
		guard let emojiDict = NSDictionary(contentsOfFile: path) as? [String:[String:Any]] else { fatalError("Cannot read emoji stats.") }
		for (emoji,stats) in emojiDict {
			let statsVal = ["happy", "popularity", "emotion", "humour", "sarcastic"].map {
				stats[$0] as? Int ?? 0
			}
			let emojiObj = Emoji(emoji: emoji, name: stats["desc"] as? String ?? "?",happiness: statsVal[0], popularity: statsVal[1], emotion: statsVal[2], humour: statsVal[3], sarcastic: statsVal[4])
			emojis.append(emojiObj)
		}
		return emojis
	}
}

