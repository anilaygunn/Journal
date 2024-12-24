//
//  Picture.swift
//  Journal
//
//  Created by Anıl Aygün on 23.12.2024.
//

import Foundation
import UIKit

class Picture: NSObject, Codable {
    
    var fileName: String
    var caption: String
    
    init(fileName: String, caption: String) {
        self.fileName = fileName
        self.caption = caption
    }
    
}
