//
//  BreadcrumbItem.swift
//  
//
//  Created by Nanashi Li on 2023/12/24.
//

import Foundation

public class BreadcrumbItem: Codable {
    var parent: BreadcrumbItem?
    var fileName: String
    var fileUrl: String
    var systemImage: String
    var children: [BreadcrumbItem]?

    public init(parent: BreadcrumbItem? = nil,
                fileName: String,
                fileUrl: String,
                systemImage: String,
                children: [BreadcrumbItem]? = nil) {
        self.parent = parent
        self.fileName = fileName
        self.fileUrl = fileUrl
        self.systemImage = systemImage
        self.children = children
    }
}
