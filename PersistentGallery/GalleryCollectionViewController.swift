//
//  GalleryCollectionViewController.swift
//  Gallery
//
//  Created by Piti Irawan on 2019/09/24.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    private var cellWidth = 160.0
    var gallery = Gallery(data: [])

    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        //galleryCollectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true

        document?.open { success in
            if success {
                self.title = self.document?.localizedName
                self.gallery = self.document?.gallery ?? Gallery(data: [])
                self.collectionView.reloadData()
            }
        }
    }

    @IBAction func zoom(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            cellWidth *= Double(sender.scale)
            flowLayout?.invalidateLayout()
            sender.scale = 1.0
        }
    }
    
    // MARK: - Document Handling
    
    var document: GalleryDocument?

    func documentChanged() {
        document?.gallery = gallery
        if document?.gallery != nil {
            document?.updateChangeCount(.done)
        }
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        if document?.gallery != nil {
            document?.thumbnail = view.snapshot
        }
        dismiss(animated: true) {
            self.document?.close()
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCollectionViewCell", for: indexPath)
        if let galleryCollectionViewCell = cell as? GalleryCollectionViewCell {
            let cellData = gallery.data[indexPath.item]
            galleryCollectionViewCell.spinner.startAnimating()
            galleryCollectionViewCell.imageView.image = nil
            let request = URLRequest(url: cellData.url)
            if let cachedResponse = URLCache.shared.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
                galleryCollectionViewCell.imageView.image = image
                galleryCollectionViewCell.spinner.stopAnimating()
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                        if let response = response, let data = data, let image = UIImage(data: data) {
                            let cachedResponse = CachedURLResponse(response: response, data: data)
                            URLCache.shared.storeCachedResponse(cachedResponse, for: request)
                            DispatchQueue.main.async {
                                galleryCollectionViewCell.imageView.image = image
                                galleryCollectionViewCell.spinner.stopAnimating()
                            }
                        }
                    }).resume()
                }
            }
        }
        return cell
    }

    // MARK: - UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: cellWidth, height: cellWidth / gallery.data[indexPath.item].aspectRatio)
    }
    
    // MARK: UICollectionViewDragDelegate
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        itemProvider.registerObject(NSURL(), visibility: .all)
        itemProvider.registerObject(UIImage(), visibility: .all)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = gallery.data[indexPath.item]
        return [dragItem]
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let cellData = item.dragItem.localObject as? Gallery.GalleryData {
                    collectionView.performBatchUpdates({
                        gallery.data.remove(at: sourceIndexPath.item)
                        gallery.data.insert(cellData, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                        documentChanged()
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                var ratio: CGFloat?
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    if let image = provider as? UIImage {
                        ratio = image.size.width / image.size.height
                    }
                }
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { [unowned self] (provider, error) in
                    if let aspectRatio = ratio {
                        DispatchQueue.main.async {
                            let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "placeholderCollectionViewCell"))
                            if let url = provider as? URL {
                                placeholderContext.commitInsertion(dataSourceUpdates: { [unowned self] insertionIndexPath in
                                    self.gallery.data.insert(Gallery.GalleryData(url: url.imageURL, aspectRatio: Double(aspectRatio)), at: insertionIndexPath.item)
                                    self.documentChanged()
                                })
                            } else {
                                placeholderContext.deletePlaceholder()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showImageDetail" {
            if let galleryCollectionViewCell = sender as? GalleryCollectionViewCell {
                if galleryCollectionViewCell.imageView.image != nil {
                    return true
                }
            }
        }
        return false
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "showImageDetail" {
            if let galleryCollectionViewCell = sender as? GalleryCollectionViewCell {
                if let image = galleryCollectionViewCell.imageView.image {
                    if let galleryScrollViewController = segue.destination as? GalleryScrollViewController {
                        galleryScrollViewController.image = image
                    }
                }
            }
        }
    }
}
