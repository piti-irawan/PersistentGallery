//
//  Document.swift
//  PersistentGallery
//
//  Created by Piti Irawan on 2019/09/26.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class GalleryDocument: UIDocument {
    var gallery = Gallery(data: [])
    var thumbnail: UIImage?

    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return gallery.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let json = contents as? Data {
            gallery = Gallery(json: json) ?? Gallery(data: [])
        }
    }

    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
}

