//
//  InputType.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-12.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

protocol InputType: ValueType {
    func _representationParameters() -> [Parameter]
}

extension InputType {
    
    var _stringRepresentation: String {
        let parameters = self._representationParameters().map {
            $0._stringRepresentation
        }.joined(separator: ", ")

        return "{\(parameters)}"
    }
}
