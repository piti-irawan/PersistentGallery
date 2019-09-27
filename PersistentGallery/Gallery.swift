//
//  Gallery.swift
//  PersistentGallery
//
//  Created by Piti Irawan on 2019/09/26.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import Foundation

struct Gallery: Codable {
    var data = [GalleryData]()
    
    struct GalleryData: Codable {
        let url: URL
        let aspectRatio: Double
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(Gallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(data: [GalleryData]) {
        self.data = data
    }
}
