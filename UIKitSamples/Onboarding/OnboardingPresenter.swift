//
//  OnboardingPresenter.swift
//  AirBill
//
//  Created by Andrey on 16.08.2022.
//
import UIKit

protocol OnboardingVCProtocol: UIViewController {
    var presenter: OnboardingPresenterProtocol { get set }
    func updatePage(model: OnboardingItemModel, scrollTo: Int, animate: Bool, hideSkip: Bool, scroll: Bool)
    func closeOnboarding()
    
}

protocol OnboardingPresenterProtocol: AnyObject {
    
    var managedView: OnboardingVCProtocol? { get set }

    var currentIndex: Int { get set }
    var items: [OnboardingItemModel] { get }
    func numberOfItems() -> Int
    func model(at index: Int) -> OnboardingItemModel?
    func setCurrentItem(at index: Int, animate: Bool, scroll: Bool)
    func setNextIndex()
}

class OnboardingPresenter: OnboardingPresenterProtocol {
    
    var currentIndex: Int = 0

    weak var managedView: OnboardingVCProtocol?
    
    var items: [OnboardingItemModel]
    
    init(){
        items = OnboardingFactory().createItems()
    }
    
    func numberOfItems() -> Int {
        return items.count
    }

    func model(at index: Int) -> OnboardingItemModel? {
        return items[safe: index]
    }

    func setNextIndex() {
        if items.count > currentIndex+1 {
            setCurrentItem(at: currentIndex+1, animate: true, scroll: true)
        }else{
            if let managedView = managedView {
                managedView.closeOnboarding()
            }
        }
    }
    
    func setCurrentItem(at index: Int, animate: Bool, scroll: Bool) {
        if let managedView = managedView, let item = items[safe: index] {
            let animate = currentIndex == index ? false : true
            currentIndex = index
            managedView.updatePage(model: item, scrollTo: index, animate: animate, hideSkip: index == items.count-1, scroll: scroll)
        }
    }
}
