//
//  FieldViewModel.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/20/21.
//

import RxCocoa
import Differentiator

public struct FieldViewModel: Equatable {
    let title: String
    let text = BehaviorRelay<String>(value: "")
    let focus = PublishRelay<Void>()
    
    init(title: String = "") {
        self.title = title
    }

    public static func == (lhs: FieldViewModel, rhs: FieldViewModel) -> Bool {
        lhs.title == rhs.title && lhs.text.value == rhs.text.value
    }
}

extension FieldViewModel: IdentifiableType {
    public var identity: String { title }
}
