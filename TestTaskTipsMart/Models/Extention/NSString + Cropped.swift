//
//  NSString + Cropped.swift
//  TestTaskTipsMart
//
//  Created by olli on 08.08.19.
//  Copyright © 2019 Oli Poli. All rights reserved.
//

import Foundation

let const = Constants()

extension String {
    
    func croppedToThirtyCharacters() -> String {
        return String(self.prefix(const.croppedString))
    }
    
}
