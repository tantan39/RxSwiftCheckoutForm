//
//  Suggestion.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/20/21.
//

import Foundation

public struct Suggestion {

    let iban: String?
    let taxNumber: String?
    
    internal init(iban: String?, taxNumber: String?) {
        self.iban = iban
        self.taxNumber = taxNumber
    }
}
