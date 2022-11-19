//
//  Validation.swift
//  ToDoList
//
//  Created by Tomi Antoljak on 11/19/22.
//  Copyright © 2022 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

enum ValidationError: Error {
    
    case Empty
    
    case Short
    
    case Long
    
}



class Validation {
    
    func validate(text: String?, minLength: Int, maxLength: Int) throws -> String {
        
        guard let text = text, !text.isEmpty else {
            
            throw ValidationError.Empty
                        
        }
        
        if text.count < minLength {
            
            throw ValidationError.Short
            
        }
        
        if text.count > maxLength {
            
            throw ValidationError.Long
            
        }
        
        return text
        
    }
    
}
