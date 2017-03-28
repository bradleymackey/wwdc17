import Foundation
import UIKit

public final class BarChartView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
	
	public var items:[CGFloat] = [200,100,340,1000,12,1200,32,123,13,4564,2342,232,345]
	
	// MARK: Init
	
	public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		
		self.backgroundColor = .white
		self.isUserInteractionEnabled = true
		self.register(BarCell.self, forCellWithReuseIdentifier: BarCell.id)
		self.delegate = self
		self.dataSource = self
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Setup Methods
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		// make each cell just the right width so that we can show them all without scrolling
		let idealWidth =  CGFloat(Int(self.frame.size.width)/Int(self.items.count))-6
		let width:CGFloat = idealWidth > 0 ? idealWidth : 1
		return CGSize(width: width, height: self.frame.height)
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 4, 0, 4)
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = self.dequeueReusableCell(withReuseIdentifier: BarCell.id, for: indexPath) as! BarCell
		if let max = items.max() {
			let value = items[indexPath.item]
			let ratio:CGFloat = value / max
			cell.barHeightConstraint?.constant = self.frame.height * ratio
		}
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
}

