//
//  Utility.swift
//  GitHubIssuesDemo
//
//  Created by Prabhat Pandey on 25/08/19.
//  Copyright © 2019 Prabhat Pandey. All rights reserved.
//

import Foundation

class Utility {
    class func createAttributedText(fullStr: String, toColor: String, colour: UIColor) -> NSMutableAttributedString {
        let main_string = fullStr
        let string_to_color = toColor
        let range = (main_string as NSString).range(of: string_to_color)
        let attribute = NSMutableAttributedString.init(string: main_string)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: colour , range: range)
        return attribute
    }
}


