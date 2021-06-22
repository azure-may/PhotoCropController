//  PushTransition.swift
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

public class PushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var duration = 0.3
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toController = transitionContext.viewController(forKey: .to),
            let fromController = transitionContext.viewController(forKey: .from)
        else { return}
        toController.view.frame.origin.x = fromController.view.frame.width
        transitionContext.containerView.addSubview(toController.view)
        UIView.animate(withDuration: duration, animations: {
            toController.view.frame.origin.x = 0
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}