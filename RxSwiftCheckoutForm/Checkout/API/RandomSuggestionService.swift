//
//  RandomSuggestionsService.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/20/21.
//

import RxSwift

class RandomSuggestionService: SuggestionService {
    func perform(request: SuggestionRequest) -> Single<[Suggestion]> {
        return .just((0...10).map({ _ in
            Suggestion(iban: "\(Int.random(in: 10000...99999))", taxNumber: "\(Int.random(in: 10000...99999))")
        }))
    }
}
