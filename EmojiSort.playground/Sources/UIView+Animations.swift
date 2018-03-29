import Foundation
import UIKit

extension UIView {
	func bounce(_ times:Int, completion: (()->Void)?) {
		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)
		let animation = CABasicAnimation(keyPath: "transform.scale")
		animation.duration = 0.15 // how long the animation will take
		animation.repeatCount = Float(times)
		animation.autoreverses = true // so it auto returns to 0 offset
		animation.fromValue = 1
		animation.toValue = 1.1
		layer.add(animation, forKey: "transform.scale")
		CATransaction.commit()
	}
	func shake(completion: (()->Void)?) {
		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)
		let animation = CABasicAnimation(keyPath: "transform.translation.x")
		animation.duration = 0.03
		animation.repeatCount = 10
		animation.autoreverses = true
		animation.fromValue = -4
		animation.toValue = 4
		layer.add(animation, forKey: "transform.translation.x")
		CATransaction.commit()
	}
	
	func setAnchorPoint(anchorPoint: CGPoint) {
		var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
		var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
		
		newPoint = newPoint.applying(self.transform)
		oldPoint = oldPoint.applying(self.transform)
		
		var position = self.layer.position
		position.x -= oldPoint.x
		position.x += newPoint.x
		
		position.y -= oldPoint.y
		position.y += newPoint.y
		
		self.layer.position = position
		self.layer.anchorPoint = anchorPoint
	}
}

