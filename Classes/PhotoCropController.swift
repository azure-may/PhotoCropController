//  PhotoCropController.swift
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

public protocol PhotoCropDelegate: NSObject {
    func cropViewDidCrop(image: UIImage?)
}

public class PhotoCropController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    //MARK: - Properties
    
    public weak var delegate: PhotoCropDelegate? = nil
    public var image: UIImage? = nil { didSet {
        imageView.image = image
        imageSize = image?.size ?? .zero
    } }
    private var imageSize: CGSize = .zero
    private var cropSize: CGSize {
        CGSize(width: view.frame.width, height: round(view.frame.width * aspectRatio))
    }
    public var dismissModally = false
    public var aspectRatio: CGFloat = 1
    
    //MARK: - Views
    
    private let scrollView = UIScrollView()
    private lazy var imageView = UIImageView()
    private let topBlurView = CropView(.blur)
    private let cropFrame = CropView(.border)
    private let bottomBlurView = CropView(.blur)
    private lazy var toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
    
    //MARK: - Navigation
    
    private var leftBarItem: UIBarButtonItem {
        UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissController))
    }
    private var rightBarItem: UIBarButtonItem {
        UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(cropImage(_:)))
    }
    private var spacer: UIBarButtonItem {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    }
    
    //MARK: - Lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTransition()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTransition()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupNavigation()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureScrollView()
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFit
        scrollView.backgroundColor = .clear
        scrollView.addSubview(imageView)
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(toolbar)
        view.insertSubview(topBlurView, aboveSubview: scrollView)
        view.insertSubview(cropFrame, aboveSubview: scrollView)
        view.insertSubview(bottomBlurView, aboveSubview: scrollView)
    }
    
    func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        topBlurView.translatesAutoresizingMaskIntoConstraints = false
        cropFrame.translatesAutoresizingMaskIntoConstraints = false
        bottomBlurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            // Toolbar
            toolbar.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Crop Frame
            cropFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cropFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cropFrame.widthAnchor.constraint(equalTo: view.widthAnchor),
            cropFrame.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: aspectRatio),
            // Blur Views
            topBlurView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBlurView.bottomAnchor.constraint(equalTo: cropFrame.topAnchor),
            bottomBlurView.topAnchor.constraint(equalTo: cropFrame.bottomAnchor),
            bottomBlurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBlurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBlurView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupNavigation() {
        toolbar.items = [leftBarItem, spacer, rightBarItem]
    }
    
    private func setupTransition() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    private func configureScrollView() {
        imageView.frame.size = imageSize
        scrollView.contentSize = CGSize(width: imageSize.width, height: imageSize.height + scrollView.frame.height - cropFrame.frame.height)
        imageView.frame.origin.y = cropFrame.frame.origin.y - scrollView.frame.origin.y
        scrollView.contentOffset.y = (scrollView.contentSize.height - scrollView.frame.height)/2
    }
    
    @objc
    func cropImage(_ sender: UIBarButtonItem) {
        guard let image = image else { return }
        let cropRect = view.convert(cropFrame.frame, to: imageView)
        guard let croppedImage = PhotoManager
                .cropImage(image, to: cropRect, scale: imageView.contentScaleFactor)
        else { return }
        dismissModally = true
        delegate?.cropViewDidCrop(image: croppedImage)
        if let nav = navigationController, !(nav is UIImagePickerController) {
            nav.popViewController(animated: true)
        } else { presentingViewController?.dismiss(animated: true) }
    }
    
    @objc
    func dismissController() {
        dismissModally = false
        if let nav = navigationController, !(nav is UIImagePickerController) {
            nav.popViewController(animated: true)
        } else { presentingViewController?.dismiss(animated: true) }
    }
    
    //MARK: - Transition Delegate

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard presented is PhotoCropController, let presenter = source.presentingViewController
        else { return nil }
        let presentationController = ModalPushPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.offset = presenter.view.convert(source.view.frame, to: nil).origin.y + 10
        return presentationController
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presented is PhotoCropController ? PushTransition() : nil
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let controller = dismissed as? PhotoCropController else { return nil }
        return controller.dismissModally ? DismissTransition() : PopTransition()
    }
}


