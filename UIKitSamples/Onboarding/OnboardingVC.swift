//
//  OnboardingVC.swift
//  AirBill
//
//  Created by Andrey on 16.08.2022.
//

import UIKit

class OnboardingVC: ViewController, OnboardingVCProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var presenter: OnboardingPresenterProtocol
    
    required init() {
        presenter = OnboardingPresenter()
        super.init(nibName: R.nib.onboardingVC.name, bundle: nil)
        presenter.managedView = self
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }
    
    func setupView(){
        presenter.setCurrentItem(at: 0, animate: false, scroll: false)
        skipButton.setTitle(R.string.localizable.onboardingSkip(), for: .normal)
        skipButton.setTitleColor(R.color.greyColor(), for: .normal)
        skipButton.titleLabel!.font = R.font.sfProTextRegular(size: 17)
        
        nextButton.roundCorners(radius: 14)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel!.font = R.font.sfProTextSemibold(size: 17)
        pageControl.pageIndicatorTintColor = R.color.lightGreyColor()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.numberOfPages = presenter.items.count
    }

    func setupCollectionView(){
        collectionView.register(OnboardingCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
    }

    // MARK: - Actions
    
    @IBAction func nextTap(_ sender: UIButton) {
        presenter.setNextIndex()
    }
    
    @IBAction func closeVC(_ sender: Any) {
        closeOnboarding()
    }
    
    
    func updatePage(model: OnboardingItemModel, scrollTo: Int, animate: Bool, hideSkip: Bool, scroll: Bool) {
        imageView.setImage(model.image, animated: animate, rotate: animate)
        if scroll {
            collectionView.scrollToItem(at: IndexPath(item: scrollTo, section: 0), at: .centeredHorizontally, animated: animate)
        }
        skipButton.isHidden = hideSkip
        pageControl.currentPage = scrollTo
        UIView.animate(withDuration: 0.3) {
            self.nextButton.backgroundColor = model.color
        }
        UIView.transition(with: nextButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.nextButton.setTitle(model.buttonText, for: .normal)
        }, completion: nil)
        
    }
    
    func closeOnboarding() {
        Settings.shared.onboardingShowed = true
        backTap()
    }

}

extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = presenter.model(at: indexPath.row),
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.reuseKey, for: indexPath) as? OnboardingCell else { return UICollectionViewCell() }
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:  CGFloat(collectionView.frame.size.width), height: CGFloat(collectionView.frame.size.height))
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width
        presenter.setCurrentItem(at: Int(currentIndex), animate: true, scroll: false)
    }
}
