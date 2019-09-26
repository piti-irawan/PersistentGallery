//
//  Document.swift
//  PersistentGallery
//
//  Created by Piti Irawan on 2019/09/26.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

