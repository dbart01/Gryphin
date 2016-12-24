//
//  Referencing.swift
//  HubCenter
//
//  Created by Dima Bart on 2016-12-12.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

protocol Referencing {
    associatedtype ReferencingType
    
    var reference: ReferencingType { get }
}
