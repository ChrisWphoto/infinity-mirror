//
//  ledBtn.swift
//  Led-Grid
//
//  Created by Christopher G Walter on 1/5/16.
//  Copyright © 2016 Christopher G Walter. All rights reserved.
//

import UIKit

enum ButtonSuprise: Int {
    case Square = 0, Star, Circle, Cake
    
    func basicDescription() -> String {
        // This function returns a basic description of the enumeration.
        switch self {
        case .Square:
            return "Square"
        case .Star:
            return "Star"
        case .Circle:
            return "Circle"
        case .Cake:
            return "Cake"
        }
    }
}

class ledBtn: UIButton {

}
