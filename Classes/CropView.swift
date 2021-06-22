//  CropView.swift
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

public class CropView: UIView {
    
    public enum Style {
        case blur
        case border
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool { return false }
    
    public convenience init(_ style: Style) {
        self.init()
        switch style {
        case .blur:
            backgroundColor = .black
            alpha = 0.3
        case .border:
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.cgColor
        }
    }
}

