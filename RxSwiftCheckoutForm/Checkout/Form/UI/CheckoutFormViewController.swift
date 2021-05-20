//
//  CheckoutFormViewController.swift
//  RxSwiftCheckoutForm
//
//  Created by Tan Tan on 5/19/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CheckoutFormViewController: UITableViewController {
    typealias Section = AnimatableSectionModel<String, CellViewModel>
    private var viewModel: CheckoutFormViewModel?
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: CheckoutFormViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let viewModel = viewModel else { return }
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.register(FieldCell.self, forCellReuseIdentifier: "FieldCell")
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<Section> { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case let .suggestion(vm):
                let cell = UITableViewCell()
                cell.textLabel?.text = vm.text
                return cell
                
            case let .field(vm):
                let cell = tableView.dequeueReusableCell(withIdentifier: "FieldCell") as! FieldCell
                cell.setViewModel(vm)
                return cell
            }
        }
        
        let sections: Observable<[Section]> = viewModel.state.map { state in
            switch state {
                case let .fields(fields):
                    return [AnimatableSectionModel(model: "Fields", items: fields.map(CellViewModel.field)) ]
                    
                case let .focus(field, suggestions):
                    return [
                        AnimatableSectionModel(model: "Fields", items: [.field(field)] ),
                        AnimatableSectionModel(model: "Suggestions", items: suggestions.map(CellViewModel.suggestion))
                                                   ]
            }
        }
        
        sections.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(CellViewModel.self)
            .subscribe(onNext: { [weak self] model in
                if case let .suggestion(vm) = model {
                    self?.view.endEditing(true)
                    vm.selection.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
}
