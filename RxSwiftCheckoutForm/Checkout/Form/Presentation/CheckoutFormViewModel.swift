//
//  CheckoutFormViewModel.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/19/21.
//

import RxCocoa
import RxSwift
import RxDataSources

struct CheckoutFormViewModel {
    
    private let iban: FieldViewModel
    private let taxNumber: FieldViewModel
    private let bankName: FieldViewModel
    private let comment: FieldViewModel
    private let service: SuggestionService
    private let selectSuggestion = PublishRelay<Void>()
    
    internal init(iban: FieldViewModel, taxNumber: FieldViewModel, bankName: FieldViewModel, comment: FieldViewModel, suggestionService: SuggestionService) {
        self.iban = iban
        self.taxNumber = taxNumber
        self.bankName = bankName
        self.comment = comment
        self.service = suggestionService
    }
    
    var state: Observable<State> {
        let allFields = State.fields([iban, taxNumber, bankName, comment])
        
        return Observable.merge(
            focus(for: iban),
            focus(for: taxNumber),

            search(for: iban),
            search(for: taxNumber),
            selectSuggestion.map{ fields in
                allFields
            },
            .just(allFields)
        )
    }
    
    private func focus(for field: FieldViewModel) -> Observable<State> {
        return field.focus.map({ [field] in
            .focus(field, [])
        })
    }
    
    private func search(for field: FieldViewModel) -> Observable<State> {
        field.text
            .skip(1)
            .distinctUntilChanged()
            .flatMap{ [service] query in
                service.perform(request: .init(query: query)).asObservable()
            }.map { [selectSuggestion] suggestions in
                .focus(field, suggestions.map({ SuggestionViewModel($0, select: selectSuggestion) }))
            }
    }
    
}

enum State: Equatable {

    case fields([FieldViewModel])
    case focus(FieldViewModel, [SuggestionViewModel])
}


extension State {
    var firstSuggestion: SuggestionViewModel? {
        switch self {
        case .focus(_, let suggestions):
            return suggestions.first
        default:
            return nil
        }
    }
    
}
