//
//  SuggestionViewModel.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/20/21.
//

import RxCocoa
import Differentiator

struct SuggestionViewModel: Equatable {
    let text: String
    let selection: PublishRelay<Void>
    
    init(_ suggetion: Suggestion) {
        self.init(suggetion, select: PublishRelay<Void>())
    }
    
    init(_ suggetion: Suggestion, select: PublishRelay<Void>) {
        switch (suggetion.iban, suggetion.taxNumber) {
        case let (.some(iban), .some(taxNumber)) :
            self.text = "Iban: \(iban) | Tax number: \(taxNumber)"
            
        case let (.none, (.some(taxNumber))):
            self.text = "Tax number: \(taxNumber)"
            
        case let ((.some(iban)), .none):
            self.text = "Iban: \(iban)"
        default:
            self.text = ""
        }
        
        self.selection = select
    }
    
    static func == (lhs: SuggestionViewModel, rhs: SuggestionViewModel) -> Bool {
        true
    }

}

extension SuggestionViewModel: IdentifiableType {
    var identity: String { text }
}
