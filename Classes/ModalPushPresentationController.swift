//  ModalPushPresentationController.swift
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

public class ModalPushPresentationController: UIPresentationController {
    
    public var offset: CGFloat = 0.0
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        containerView?.frame.origin.y = offset
        containerView?.frame.size.height -= offset
        containerView?.layer.cornerRadius = 10
        containerView?.clipsToBounds = true
    }
}
