//
//  GalleryScrollViewController.swift
//  Gallery
//
//  Created by Piti Irawan on 2019/09/25.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class GalleryScrollViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    var image = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1.2
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        scrollView.contentSize = image.size
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let widthScale = view.bounds.width / imageView.bounds.width
        let heightScale = view.bounds.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = min(0.8, minScale)
        scrollView.zoomScale = min(0.99, minScale)
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let yOffset = max(0, (view.bounds.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (view.bounds.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        view.layoutIfNeeded()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
