import Foundation
import UIKit


/// To be adopted by any reciever that wants to recieve info about when the user selects a new algorithm, trait or speed.
public protocol OptionChangeReactable: class {
	func algorithmChanged(to algorithm:Sorter.Algorithm)
	func traitChanged(to trait:Emoji.Trait)
	func speedChanged(to speed:AlgorithmSpeed)
}


public final class OptionView: UIView {
	
	// MARK: Labels
	
	public var sortByLabel = UILabel(frame: .zero)
	public var algorithmLabel = UILabel(frame: .zero)
	public var 
	
	// MARK: Buttons
	
	
	
	
	
	
	
	
	
	
	
	
	
}
