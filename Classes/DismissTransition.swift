//  DismissTransition.swift
//  Pods
//
//  Created by: Azure May Burmeister on 6/22/21
//  
//
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import PhotosUI

public class DismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var duration = 0.3
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let toController = transitionContext.viewController(forKey: .to),
              let fromView = transitionContext.view(forKey: .from),
              let snapshot = fromView.snapshotView(afterScreenUpdates: true)
        else { return}
        snapshot.frame = fromView.frame
        container.addSubview(snapshot)
        if #available(iOS 14, *), toController is PHPickerViewController {
            (toController.view.superview ?? toController.view)?.isHidden = true
        } else if toController is UIImagePickerController {
            (toController.view.superview ?? toController.view)?.isHidden = true
        }
        fromView.isHidden = true
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            snapshot.frame.origin.y = snapshot.frame.height
        }, completion: { _ in
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

