import Foundation

/// # Sortable
/// A protocol to which all sortable types conform that have traits.
public protocol TraitSortable {
	var traits:[Emoji.Trait:Int] { get }
}

