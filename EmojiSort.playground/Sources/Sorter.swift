//
//  Sorter.swift
//
//
//  Created by Bradley Mackey on 14/03/2017.
//
//

import Foundation

// THE FOLLOWING CONTAINS MODIFIED PORTIONS FROM: https://github.com/raywenderlich/swift-algorithm-club
// (LICENECED UNDER THE MIT LICENCE):
//
//	Copyright (c) 2016 Matthijs Hollemans and contributors
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

// extension modified from: http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension MutableCollection where Indices.Iterator.Element == Index {
	/// Shuffles the contents of this collection, producing steps
	func stepsToShuffle() -> [AlgorithmStep] {
		var list = self
		let c = count
		guard c > 1 else { return [] }
		
		var steps = [AlgorithmStep]()
		
		for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			guard d != 0 else { continue }
			let i = index(firstUnshuffled, offsetBy: d)
			swap(&list[firstUnshuffled], &list[i])
			let swapStep = AlgorithmStep(swap: firstUnshuffled as! Int, with: i as! Int)
			steps.append(swapStep)
		}
		
		return steps
	}
}

/// # Sorter
/// The brain of the program. This contains methods to sort a given list of `Sortable` by a number of sorting algorithms and gives the steps to produce such a sorted list.
/// - important: the output of all of these functions is not the direct sorted lists that were input, rather a sequence of `AlgorithmStep`s required to reproduce the sorted list.
/// - important: when sorting by trait, be sure all elements have the required trait, otherwise the program will CRASH (by design)
public final class Sorter {
	
	// MARK: Enums
	
	/// The sorting algorithms `Sorter` is capable of performing.
	public enum Algorithm {
		case bubbleSort // ✅ instructions working
		case insertionSort // ✅ instructions working
		case selectionSort // ✅ instructions working
		case mergeSort // ✅ instructions working
		case quickSort // ✅ instructions working
		case stupidSort // ✅ instructions working
	}
	
	// MARK: Methods
	
	/// Sorts a provided list of `TraitSortable`s by a given `trait` using an algoritm defined in `Sorter.Algorithm`
	/// - parameter objects: an unsorted array of `TraitSortable`
	/// - parameter trait: the trait by which to sort
	/// - parameter algorithm: the sorting algorithm that should be used to sort, defined in `Sorter.Algorithm`
	/// - returns: the steps required to reproduce this sort or `nil` if not all `TraitSortable` objects have the required `trait` or there are no objects.
	public static func sort<T: TraitSortable>(objects:[T], with trait:Emoji.Trait, using algorithm:Algorithm) -> [AlgorithmStep]? {
		// we require more than 0 objects to be passed to the sort function
		guard objects.count > 0 else { return nil }
		// use the selected algorithm to sort the elements
		switch algorithm {
		case .bubbleSort:
			return bubbleSort(on: objects, using: trait)
		case .insertionSort:
			return insertionSort(on: objects, using: trait)
		case .selectionSort:
			return selectionSort(on: objects, using: trait)
		case .mergeSort:
			mergeSortSteps = []
			mergeSort(on: objects, using: trait)
			return mergeSortSteps
		case .quickSort:
			quickSortSteps = []
			quickSort(on: objects, using: trait)
			return quickSortSteps
		case .stupidSort:
			return stupidSort(on: objects, using: trait)
		}
	}
	
	public static func randomisePositions<T: TraitSortable>(objects:[T]) -> [AlgorithmStep] {
		return stupidSort(on: objects,
		                  using: .happiness, // doesn't matter in this case
		                  times: 1)
	}
	
	/// - returns: the steps required to produce the sorted list, or nil if the sorting `trait` does not exist on any object.
	private static func bubbleSort<T: TraitSortable>(on objects:[T], using trait:Emoji.Trait) -> [AlgorithmStep]? {
		var steps = [AlgorithmStep]()
		var sortedAboveIndex = objects.count // Assume all values are not in order
		var sortedArray = objects
		while sortedAboveIndex != 0 {
			var lastSwapIndex = 0
			for i in 1 ..< sortedAboveIndex {
				guard let firstTrait = sortedArray[i - 1].traits[trait], let secondTrait = sortedArray[i].traits[trait] else { return nil }
				let highlightStep = AlgorithmStep(highlightIndex: i, and: i-1, withIntensity: .small)
				steps.append(highlightStep)
				if (firstTrait > secondTrait) {
					swap(&sortedArray[i], &sortedArray[i-1])
					lastSwapIndex = i
					let bigHighlight = AlgorithmStep(highlightIndex: i, and: i-1, withIntensity: .large)
					let swapStep = AlgorithmStep(swap: i, with: i-1)
					steps += [bigHighlight,swapStep]
				}
			}
			sortedAboveIndex = lastSwapIndex
		}
		return steps
	}
	
	/// - returns: the steps required to produce the sorted list, or nil if the sorting `trait` does not exist on any object.
	private static func insertionSort<T: TraitSortable>(on objects:[T], using trait:Emoji.Trait) -> [AlgorithmStep]? {
		var sortedObjects = objects
		var steps = [AlgorithmStep]()
		for i in 1..<sortedObjects.count {
			var a = i
			let temp = sortedObjects[a]
			let hold = AlgorithmStep(hold: a)
			let highlight = AlgorithmStep(highlightIndex: a, withIntensity: .small)
			steps += [hold,highlight]
			guard let firstTrait = temp.traits[trait], let secondTrait = sortedObjects[a-1].traits[trait] else { return nil }
			while a > 0 && firstTrait < secondTrait {
				let match = AlgorithmStep(match: a, with: a-1)
				steps.append(match)
				sortedObjects[a] = sortedObjects[a-1]
				a -= 1
			}
			let matchBack = AlgorithmStep(match: a, with: nil)
			let removeHold = AlgorithmStep(type: .unhold)
			steps += [matchBack,removeHold]
			sortedObjects[a] = temp
		}
		return steps
	}
	
	/// - returns: the steps required to produce the sorted list, or nil if the sorting `trait` does not exist on any object.
	private static func selectionSort<T: TraitSortable>(on objects:[T], using trait:Emoji.Trait) -> [AlgorithmStep]? {
		var sortedObjects = objects
		var steps = [AlgorithmStep]()
		for x in 0 ..< sortedObjects.count - 1 {
			// Find the lowest value in the rest of the array.
			var lowest = x
			for y in x + 1 ..< sortedObjects.count {
				let highlight = AlgorithmStep(highlightIndex: y, withIntensity: .small)
				steps.append(highlight)
				guard let firstTrait = sortedObjects[y].traits[trait], let secondTrait = sortedObjects[lowest].traits[trait] else { return nil }
				if firstTrait < secondTrait {
					lowest = y
				}
			}
			// Swap the lowest value with the current array index.
			if x != lowest {
				swap(&sortedObjects[x], &sortedObjects[lowest])
				let highlight = AlgorithmStep(highlightIndex: x, and: lowest, withIntensity: .large)
				let swapStep = AlgorithmStep(swap: x, with: lowest)
				steps += [highlight,swapStep]
			}
		}
		return steps
	}
	
	// TODO: Steps for mergeSort
	
	/// As `mergeSort` is a recursive algorithm, we store all the algorithm steps outside of the function itself while it is running.
	private static var mergeSortSteps = [AlgorithmStep]()
	
	/// - parameter indexOffset: used to keep track of the current position in the recursion, so we know where to apply the animation.
	@discardableResult
	private static func mergeSort<T: TraitSortable>(on objects:[T], using trait:Emoji.Trait, indexOffset:Int=0) -> [T]? {
		guard objects.count > 1 else { return objects }
		let middleIndex = objects.count/2
		let split = AlgorithmStep(splitBetween: (middleIndex-1)+indexOffset, and: middleIndex+indexOffset)
		mergeSortSteps.append(split)
		guard let left = mergeSort(on: Array(objects[0..<middleIndex]), using: trait, indexOffset: indexOffset) else { return nil }
		guard let right = mergeSort(on: Array(objects[middleIndex..<objects.count]), using: trait, indexOffset: indexOffset+middleIndex) else { return nil }
		return merge(left: left, right: right, leftOffset: indexOffset, rightOffset: indexOffset+middleIndex, using: trait)
	}
	
	/// - returns: an ordered merged, ordered list of `left` and `right` or nil if not all objects have the required `trait`
	private static func merge<T: TraitSortable>(left: [T], right: [T], leftOffset:Int,rightOffset:Int, using trait:Emoji.Trait) -> [T]? {
		var leftIndex = 0
		var rightIndex = 0
		var orderedPile = [T]()
		if orderedPile.capacity < left.count + right.count {
			orderedPile.reserveCapacity(left.count + right.count)
		}
		var additionalOffset = 0
		while leftIndex < left.count && rightIndex < right.count {
			defer { additionalOffset += 1 }
			guard let leftTrait = left[leftIndex].traits[trait], let rightTrait = right[rightIndex].traits[trait] else { return nil }
			if leftTrait < rightTrait {
				let moveLeft = AlgorithmStep(moveToJoiningArea: leftIndex+leftOffset, toJoiningAreaIndexPosition: leftOffset+additionalOffset)
				mergeSortSteps.append(moveLeft)
				orderedPile.append(left[leftIndex])
				leftIndex += 1
			} else if leftTrait > rightTrait {
				let moveRight = AlgorithmStep(moveToJoiningArea: rightIndex+rightOffset, toJoiningAreaIndexPosition: leftOffset+additionalOffset)
				mergeSortSteps.append(moveRight)
				orderedPile.append(right[rightIndex])
				rightIndex += 1
			} else {
				let moveLeft = AlgorithmStep(moveToJoiningArea: leftIndex+leftOffset, toJoiningAreaIndexPosition: leftOffset+additionalOffset)
				mergeSortSteps.append(moveLeft)
				orderedPile.append(left[leftIndex])
				leftIndex += 1
				additionalOffset += 1 // make sure to add an extra one here!
				let moveRight = AlgorithmStep(moveToJoiningArea: rightIndex+rightOffset, toJoiningAreaIndexPosition: leftOffset+additionalOffset)
				mergeSortSteps.append(moveRight)
				orderedPile.append(right[rightIndex])
				rightIndex += 1
			}
		}
		while leftIndex < left.count {
			defer { additionalOffset += 1 }
			let moveLeft = AlgorithmStep(moveToJoiningArea: leftIndex+leftOffset, toJoiningAreaIndexPosition: leftOffset+additionalOffset)
			mergeSortSteps.append(moveLeft)
			orderedPile.append(left[leftIndex])
			leftIndex += 1
		}
		while rightIndex < right.count {
			defer { additionalOffset += 1 }
			let moveRight = AlgorithmStep(moveToJoiningArea: rightIndex+rightOffset, toJoiningAreaIndexPosition: leftOffset+additionalOffset)
			mergeSortSteps.append(moveRight)
			orderedPile.append(right[rightIndex])
			rightIndex += 1
		}
		let backStep = AlgorithmStep(type: .mergeComplete)
		mergeSortSteps.append(backStep)
		return orderedPile
	}
	
	
	// TODO: the steps for quicksort, currently it will sort, but we only have steps for getting and dropping the pivot
	
	//// As `quickSort` is a recursive algorithm, we store all the algorithm steps outside of the function itself while it is running.
	private static var quickSortSteps = [AlgorithmStep]()
	
	/// - note: as this is a recursive algorithm, we need to store an `indexOffset` so we know whereabouts in the recursion we are.
	@discardableResult
	private static func quickSort<T: TraitSortable>(on objects:[T], using trait:Emoji.Trait, indexOffset:Int=0) -> [T] {
		// base case -> we don't need to sort a single element
		guard objects.count > 1 else { return objects }
		
		// select pivot
        let pivotIndex = objects.count/2
		let pivotTraitValue = objects[pivotIndex].traits[trait]!
		let selectPivot = AlgorithmStep(type: .selectPivot, mainIndex: pivotIndex+indexOffset)
		quickSortSteps.append(selectPivot)
		
		// THE FOLLOWING SORTING ORDER IS IMPORTANT,DO NOT CHANGE
		
		// objects less than the current pivot value
        var lessIndexNo = 0
        var less = [T]()
        for obj in objects {
            defer { lessIndexNo += 1 }
            if obj.traits[trait]! < pivotTraitValue {
                less.append(obj)
                let moveStep = AlgorithmStep(move: lessIndexNo+indexOffset, before: pivotIndex+indexOffset)
                quickSortSteps.append(moveStep)
            }
        }

		// objects more than the current pivot value
        var greaterIndexNo = 0
        var greaterMatches = 0
        var greater = [T]()
        for obj in objects {
            defer { greaterIndexNo += 1 }
            if obj.traits[trait]! > pivotTraitValue {
                greater.append(obj)
                let moveStep = AlgorithmStep(move: greaterIndexNo+indexOffset, after: pivotIndex+indexOffset+greaterMatches)
                quickSortSteps.append(moveStep)
                greaterMatches += 1
            }
        }
		
		// objects that are currently equal to the pivot
        var equalIndexNo = 0
        var equal = [T]()
        for obj in objects {
            defer { equalIndexNo += 1 }
            if obj.traits[trait]! == pivotTraitValue {
                equal.append(obj)
				// ensure that we don't move the pivot element itself
				guard equalIndexNo+indexOffset != pivotIndex+indexOffset else { continue }
				let moveStep = AlgorithmStep(move: equalIndexNo+indexOffset, after: pivotIndex+indexOffset)
				quickSortSteps.append(moveStep)
            }
        }
		
		// work is done, we can drop the current pivot
		let dropPivot = AlgorithmStep(type: .dropPivot)
		quickSortSteps.append(dropPivot)
        return quickSort(on: less, using: trait, indexOffset: indexOffset) + equal + quickSort(on: greater, using: trait, indexOffset: pivotIndex+equal.count+indexOffset)
	}
	
	/// This algorithm doesn't actually require the elements eventually get sorted, just do a few iterations to show how bad it is.
	private static func stupidSort<T: TraitSortable>(on objects:[T], using trait:Emoji.Trait, times:Int=5) -> [AlgorithmStep] {
		var steps = [AlgorithmStep]()
		for _ in 0..<times {
			steps += objects.stepsToShuffle()
		}
		return steps
	}

}

