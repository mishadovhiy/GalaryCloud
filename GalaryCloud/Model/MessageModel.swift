//
//  MessageModel.swift
//  GalaryCloud
//
//  Created by Mykhailo Dovhyi on 17.11.2025.
//

import Foundation

struct MessageModel: Codable, Equatable {
    let title: String
    let buttons: [ButtonModel]
    
    init(title: String, buttons: [ButtonModel] = []) {
        self.title = title
        self.buttons = buttons
    }
}

struct ButtonModel: Codable, Equatable {
    static func == (lhs: ButtonModel, rhs: ButtonModel) -> Bool {
        ![lhs.title == rhs.title].contains(false)
    }
    
    let title: String
    var didPress: (() -> Void)? = nil
    
    enum CodingKeys: CodingKey {
        case title
    }
}
