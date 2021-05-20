//
//  CellViewModel.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/20/21.
//

import Differentiator

enum CellViewModel: IdentifiableType, Equatable {
    case field(FieldViewModel)
    case suggestion(SuggestionViewModel)
    
    var identity: String {
        switch self {
        case let .field(vm):
            return vm.identity
        case let .suggestion(vm):
            return vm.identity
        
        }
    }
}
