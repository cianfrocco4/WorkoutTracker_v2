//
//  TextBindingManager.swift
//  WorkoutTracker_v2
//
//  Created by Anthony Cianfrocco on 2/3/23.
//

import Foundation

class TextBindingManager: ObservableObject {
    @Published var text = "" {
        didSet {
            if text.count > characterLimit && oldValue.count <= characterLimit {
                text = oldValue
            }
        }
    }
    let characterLimit: Int

    init(limit: Int = 3){
        characterLimit = limit
    }
}
