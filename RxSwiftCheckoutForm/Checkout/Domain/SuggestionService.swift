//
//  SuggestionsService.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/20/21.
//

import RxSwift

public protocol SuggestionService {
    func perform(request: SuggestionRequest) -> Single<[Suggestion]>
}

public struct SuggestionRequest {
    let query: String
}

