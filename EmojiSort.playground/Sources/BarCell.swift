import Foundation
import UIKit

public final class BarCell: UICollectionViewCell {
	
	// MARK: Statics
	
	public static let id = "barCell"
	
	// MARK: Properties
	
	private let barView: UIView = {
		let view = UIView()
		view.backgroundColor = .blue
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	public var barHeightConstraint: NSLayoutConstraint?
	
	// MARK: Init
	
	override public init(frame:CGRect) {
		super.init(frame: frame)
		
		// add the barView
		self.addSubview(barView)
		
		// setup bar anchors
		barHeightConstraint = barView.heightAnchor.constraint(equalToConstant: 300)
		barHeightConstraint?.isActive = true
		barView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		barView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		barView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

