//
//  OPDSParser.swift
//  readium-opds
//
//  Created by Geoffrey Bugniot on 22/05/2018.
//  Copyright © 2018 Readium. All rights reserved.
//

import Foundation
import PromiseKit
import R2Shared

public enum OPDSParserError: Error {
    
    case documentNotFound
    case documentNotValid
    
    var localizedDescription: String {
        switch self {
        case .documentNotFound:
            return "Document is not found"
        case .documentNotValid:
            return "Document is not valid"
        }
    }
    
}

public class OPDSParser {
    
    /// Parse an OPDS feed.
    /// Feed can be v1 (XML) or v2 (JSON).
    /// - parameter url: The feed URL
    /// - Returns: A promise with the resulting Feed
    public static func parseURL(url: URL) -> Promise<Feed> {
        
        return Promise<Feed> {fulfill, reject in
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                // Basically, catch networking errors
                guard error == nil else {
                    reject(error!)
                    return
                }
                
                // Ressource not found
                guard let data = data else {
                    reject(OPDSParserError.documentNotFound)
                    return
                }
                
                // We try to parse as an OPDS v1 feed,
                // then, if it fails, we try as an OPDS v2 feed.
                if let feed = try? OPDS1Parser.parse(xmlData: data, url: url) {
                    fulfill(feed)
                } else {
                    if let feed = try? OPDS2Parser.parse(jsonData: data, url: url) {
                        fulfill(feed)
                    } else {
                        // Not a valid OPDS ressource
                        reject(OPDSParserError.documentNotValid)
                    }
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
}
