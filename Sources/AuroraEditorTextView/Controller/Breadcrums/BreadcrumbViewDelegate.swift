//
//  BreadcrumbViewDelegate.swift
//  
//
//  Created by Nanashi Li on 2023/12/24.
//

import Foundation

protocol BreadcrumbViewDelegate: AnyObject {
    func breadcrumbView(_ breadcrumbView: BreadcrumbView, didSelectItemAt index: Int)
}
