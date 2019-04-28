//
//  Menu.swift
//  VoiceBox
//
//  Created by Aminda Pereira on 4/18/19.
//  Copyright © 2019 Aminda Pereira. All rights reserved.
//

import UIKit

struct Menu {
    
    let title: String
    let image: UIImage?
    
    init (title: String, image: UIImage?) {
        self.title = title
        self.image = image
    }
    
    static func faveMenu() -> [Menu] {
        return[
        ]
    }
 
 static func hamMenu() -> [Menu] {
    return [
        Menu(title:"Instructions", image: nil),
        Menu(title:"Saved List", image: nil)
    ]
 }
 
    
}
