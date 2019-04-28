//
//  Phrases.swift
//  testingfirebase
//
//  Created by user151028 on 4/11/19.
//  Copyright © 2019 Nick Brady. All rights reserved.
//

import Foundation
import Firestore

protocol DocumentSerializable {
    init?(dictionary:[String:Any])
}

struct Phrases {
    var phrase:String
    var timeStamp:Date
    
    var dictionary:[String:Any] {
        return [
            "phrase":phrase,
            "timeStamp":timeStamp
        ]
    }
}

extension Phrases : DocumentSerializable {
    init?(dictionary: [String : Any]) {
        guard let phrase = dictionary["phrase"] as? String,
            let timeStamp = dictionary["timeStamp"] as? Date else {return nil}
        
        self.init(phrase: phrase, timeStamp: timeStamp)
    }
}
