//
//  CheckoutFormViewModelTests.swift
//  RxSwiftCheckoutFormTests
//
//  Created by Tan Tan on 5/19/21.
//

import XCTest
import RxCocoa
import RxSwift

@testable import RxSwiftCheckoutForm
class FieldViewModelTests: XCTestCase {
    func test_isEqual_whenTitleAndTestMatches() {
        let f1 = FieldViewModel(title: "a title")
        let f2 = FieldViewModel(title: "another title")

        XCTAssertNotEqual(f1, f2)
        XCTAssertEqual(f1, f1)

        let f3 = FieldViewModel(title: "a title")
        f3.text.accept("a text")

        XCTAssertNotEqual(f1, f3)
    }
}



class SuggestionViewModelTests: XCTestCase {
    
    func test_text_isBasedOnProvidedSuggestionValues() {
        let suggestion = Suggestion(iban: "123", taxNumber: "456")
        let sut = SuggestionViewModel(suggestion)
        
        XCTAssertEqual(sut.text, "Iban: 123 | Tax number: 456")
    }
    
    func test_textWithoutIban_isBasedOnProvidedSuggestionValues() {
        let suggestion = Suggestion(iban: nil, taxNumber: "456")
        let sut = SuggestionViewModel(suggestion)
        
        XCTAssertEqual(sut.text, "Tax number: 456")
    }
    
    func test_textWithoutTaxNumber_isBasedOnProvidedSuggestionValues() {
        let suggestion = Suggestion(iban: "123", taxNumber: nil)
        let sut = SuggestionViewModel(suggestion)
        
        XCTAssertEqual(sut.text, "Iban: 123")
    }
    
    
}

class CheckoutFormViewModelTests: XCTestCase {
    
    func test_initialState_includesAllFormFields() {
        let (sut, fields) = makeSUT()
        let stateSpy = StateSpy(observable: sut.state)

        XCTAssertEqual(stateSpy.value, [.fields(fields.all)])
    }
    
    func test_ibanFocusedState_includesOnlyIbanField() {
        let (sut, fields) = makeSUT()
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.iban.focus.accept(())
        
        XCTAssertEqual(stateSpy.value, [
            .fields(fields.all),
            .focus(fields.iban, [])
        ])
    }
    
    func test_taxNumberFocusedState_includesOnlyTaxNumberField() {
        let (sut, fields) = makeSUT()
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.taxNumber.focus.accept(())
        
        XCTAssertEqual(stateSpy.value, [
            .fields(fields.all),
            .focus(fields.taxNumber, [])
        ])
    }
    
    func test_bankNameFocusedState_doesntChangeState() {
        let (sut, fields) = makeSUT()
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.bankName.focus.accept(())
        
        XCTAssertEqual(stateSpy.value, [.fields(fields.all)])
    }
    
    func test_commentFocusedState_doesntChangeState() {
        let (sut, fields) = makeSUT()
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.comment.focus.accept(())
        
        XCTAssertEqual(stateSpy.value, [.fields(fields.all)])
    }

    func test_ibanTextChangeState_providesSuggestionBasedOnText() {
        let service = SuggestionServiceStub()
        
        let (sut, fields) = makeSUT(service: service)
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.iban.text.accept(service.stub.query)
        fields.iban.text.accept(service.stub.query)
        
        XCTAssertEqual(stateSpy.value, [
            .fields(fields.all),
            .focus(fields.iban, service.stub.suggestions.map(SuggestionViewModel.init))
        ])
    }

    func test_taxNumberTextChangeState_providesSuggestionBasedOnText() {
        let service = SuggestionServiceStub()
        
        let (sut, fields) = makeSUT(service: service)
        let state = StateSpy(observable: sut.state)
        
        fields.taxNumber.text.accept(service.stub.query)
//        fields.taxNumber.text.accept(service.stub.query)
        
        XCTAssertEqual(state.value, [
            .fields(fields.all),
            .focus(fields.taxNumber, service.stub.suggestions.map(SuggestionViewModel.init))
        ])
    }
    
    func test_bankNameTextChangeState_doesntChangeState() {
        let service = SuggestionServiceStub()
        
        let (sut, fields) = makeSUT(service: service)
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.bankName.text.accept("any query")
        
        XCTAssertEqual(stateSpy.value, [.fields(fields.all)])
    }
    
    func test_commentTextChangeState_doesntChangeState() {
        let service = SuggestionServiceStub()
        
        let (sut, fields) = makeSUT(service: service)
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.comment.text.accept("any query")
        
        XCTAssertEqual(stateSpy.value, [.fields(fields.all)])
    }
    
    func test_ibanSuggestionSelectedState_includesAllFields() throws {
        let service = SuggestionServiceStub()
        
        let (sut, fields) = makeSUT(service: service)
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.iban.text.accept(service.stub.query)
        let suggestion = try XCTUnwrap(stateSpy.value.last?.firstSuggestion , "Expected suggestion in current state")
        suggestion.selection.accept(())
        
        XCTAssertEqual(stateSpy.value, [
            .fields(fields.all),
            .focus(fields.iban, service.stub.suggestions.map(SuggestionViewModel.init)),
            .fields(fields.all)
        ])
    }

    func test_taxNumberSuggestionSelectedState_includesAllFields() throws {
        let service = SuggestionServiceStub()
        
        let (sut, fields) = makeSUT(service: service)
        let stateSpy = StateSpy(observable: sut.state)
        
        fields.taxNumber.text.accept(service.stub.query)
        let suggestion = try XCTUnwrap(stateSpy.value.last?.firstSuggestion , "Expected suggestion in current state")
        suggestion.selection.accept(())
        
        XCTAssertEqual(stateSpy.value, [
            .fields(fields.all),
            .focus(fields.taxNumber, service.stub.suggestions.map(SuggestionViewModel.init)),
            .fields(fields.all)
        ])
    }

    
    private func makeSUT(service: SuggestionServiceStub = .init()) -> (
        sut: CheckoutFormViewModel,
        fields: (iban: FieldViewModel,
        taxNumber: FieldViewModel,
        bankName: FieldViewModel,
        comment: FieldViewModel,
        all: [FieldViewModel]))
    {
        let iban = FieldViewModel()
        let taxNumber = FieldViewModel()
        let bankName = FieldViewModel()
        let comment = FieldViewModel()
        
        let sut = CheckoutFormViewModel(iban: iban, taxNumber: taxNumber, bankName: bankName, comment: comment, suggestionService: service)
        
        return (sut, (iban, taxNumber, bankName, comment, [iban, taxNumber, bankName, comment]))
    }
    
    class SuggestionServiceStub: SuggestionService {
        let stub = (query: "a query", suggestions: [
                        Suggestion(iban: "111", taxNumber: "222"),
                        Suggestion(iban: "333", taxNumber: "444")])
        
        func perform(request: SuggestionRequest) -> Single<[Suggestion]> {
            return .just(request.query == stub.query ? stub.suggestions : [])
        }
    }
    
    class StateSpy {
        private(set) var value: [State] = []
        private let disposeBag = DisposeBag()
        
        init(observable: Observable<State>) {
            observable.subscribe(onNext: { [weak self] state in
                self?.value.append(state)
            })
            .disposed(by: disposeBag)
        }
    }
}

