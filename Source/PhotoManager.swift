//  PhotoManager.swift
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

import PhotosUI

public struct PhotoManager {
    
    public typealias Completion = () -> Void
    
    enum Message {
        static let service = "Photos"
        static let restricted = "restricted"
        static let off = "not authorized"
    }
    
    public static func cropImage(_ image: UIImage, to cropRect: CGRect, scale: CGFloat) -> UIImage? {
        let cropZone = CGRect(x:cropRect.origin.x * scale, y:cropRect.origin.y * scale, width:cropRect.size.width * scale, height:cropRect.size.height * scale)
        guard let croppedImage: CGImage = image.cgImage?.cropping(to:cropZone)
        else { return nil }
        return UIImage(cgImage: croppedImage)
    }
    
    @available(iOS 13.0, *)
    public static func resize(image: UIImage, to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    public static func initializePhotoLibrary(_ controller: UIViewController, _ completion: @escaping Completion) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            DispatchQueue.main.async { requestAuthorization(completion) }
        case .restricted:
            controller.present(alert(Message.service, reason: Message.restricted), animated: true)
        case .denied:
            controller.present(alert(Message.service, reason: Message.off), animated: true)
        case .authorized, .limited:
            DispatchQueue.main.async { completion() }
        @unknown default:
            controller.present(alert(Message.service, reason: Message.off), animated: true)
        }
    }

    public static func requestAuthorization(_ completion: @escaping Completion) {
        PHPhotoLibrary.requestAuthorization {
            switch $0 {
            case .authorized, .limited:
                DispatchQueue.main.async { completion() }
            default: return
            }
        }
    }
    
    public static func alert(_ setting: String, reason: String) -> UIAlertController {
        
        let alertController = UIAlertController (title: "\(setting.capitalized)  Settings", message: "\(setting.capitalized) services are \(reason). To enable \(setting.lowercased()) services, go to settings.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in

            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}
