//
//  Utility.swift
//  CardReader
//
//  Created by Michael Thornton on 10/7/21.
//

import Foundation
import UIKit



extension String {
    
    var fullRange: Range<String.Index> {
        //TODO : this is dangerous, but not really.  How could this ever fail?
        range(of: self)!
    }
    
    
    var isName: Bool {
        
        var nameFound = false
        
        let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
        tagger.string = self.lowercased().capitalized

        let range = NSRange(location:0, length: self.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NSLinguisticTag] = [.personalName]
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (self as NSString).substring(with: tokenRange)
                
                // all kinds of garbage can parse as a name
                // playing it safe, if the whole string is not the name then assume it is not a name
                nameFound = (name.count == self.count)
            }
        }
        
        return nameFound
    }
    
    
    
    var parsedName: String? {
        
        var name: String?
        
        let tagger = NSLinguisticTagger(tagSchemes: [.nameType], options: 0)
        tagger.string = self

        let range = NSRange(location:0, length: self.utf16.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NSLinguisticTag] = [.personalName]
        
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                name = (self as NSString).substring(with: tokenRange)
            }
        }
                
        return name
    }
} // end extension
