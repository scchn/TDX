//
//  CCTVSourcePickerController.swift
//  TDX
//
//  Created by scchn on 2022/10/28.
//

import Cocoa

import RxSwift

extension CCTVSourcePickerController {
    
    static func instantiate(_ completion: @escaping (CCTVSource) -> Void) -> CCTVSourcePickerController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateController(withIdentifier: "CCTVSourcePickerController")
            as! CCTVSourcePickerController
        vc.completion = completion
        return vc
    }
    
}

class CCTVSourcePickerController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var categoryPicker: NSPopUpButton!
    @IBOutlet private weak var cityPicker: NSPopUpButton!
    @IBOutlet private weak var okButton: NSButton!
    
    // MARK: - Data
    
    private let disposeBag = DisposeBag()
    private let viewModel = CCTVSourcePickerViewModel()
    private var completion: ((CCTVSource) -> Void)?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBinding()
    }
    
    // MARK: - UI Methods
    
    private func setupUI() {
        let categoryNames = CCTVSourceCategory.allCases.map(\.description)
        
        categoryPicker.removeAllItems()
        categoryPicker.addItems(withTitles: categoryNames)
        
        let cityNames = City.allCases.map(\.description)
        
        cityPicker.removeAllItems()
        cityPicker.addItems(withTitles: cityNames)
    }
    
    private func close() {
        guard let window = view.window else {
            return
        }
        window.sheetParent?.endSheet(window)
    }
    
    // MARK: - UI Actions
    
    @IBAction private func cancelButtonAction(_ sender: Any) {
        close()
    }
    
}

// MARK: - Binding

extension CCTVSourcePickerController {
    
    private var categoryIndexBinding: Binder<Int> {
        .init(categoryPicker) { picker, index in
            picker.selectItem(at: index)
        }
    }
    
    private var cityIndexBinding: Binder<Int> {
        .init(cityPicker) { picker, index in
            picker.selectItem(at: index)
        }
    }
    
    private var sourceBinding: Binder<CCTVSource> {
        .init(self) { vc, source in
            vc.completion?(source)
            vc.close()
        }
    }
    
    private func setupBinding() {
        let input = CCTVSourcePickerViewModel.Input(
            selectCategory: categoryPicker.rx.select.asDriver(),
            selectCity: cityPicker.rx.select.asDriver(),
            makeCategory: okButton.rx.tap.asDriver()
        )
        let output = viewModel.transform(input)
        
        disposeBag.insert([
            output.categoryIndex.drive(categoryIndexBinding),
            output.canSelectCity.drive(cityPicker.rx.isEnabled),
            output.cityIndex.drive(cityIndexBinding),
            output.makeSource.drive(sourceBinding),
        ])
    }
    
}
