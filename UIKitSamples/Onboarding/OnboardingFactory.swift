//
//  OnboardingFactory.swift
//  AirBill
//
//  Created by Andrey on 16.08.2022.
//

import UIKit

struct OnboardingItemModel {
    let image: UIImage
    let title: String
    let text: String
    let boldStrings: String
    let color: UIColor
    let buttonText: String
    
    var attributedText: NSAttributedString {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.08
            paragraphStyle.alignment = .center
            
            let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: R.font.sfProTextRegular(size: 17) ?? UIFont.systemFont(ofSize: 17), NSAttributedString.Key.kern: -0.41, NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: UIColor.black] )
            boldStrings.components(separatedBy: " ").forEach { string in
                let range = (text as NSString).range(of: string)
                attributedText.addAttributes([NSAttributedString.Key.font : R.font.sfProTextSemibold(size: 17) ?? UIFont.boldSystemFont(ofSize: 17)], range: range)
            }
            return attributedText
        }
    }
}

class OnboardingFactory: NSObject {

    func createItems() -> [OnboardingItemModel] {
        
        return [
            OnboardingItemModel(image: R.image.airbillOnboarding()!,
                                title: R.string.localizable.onboardingAirBill(preferredLanguages: [Settings.shared.langRawValue]),
                                text: R.string.localizable.onboardingAirBillInfo(preferredLanguages: [Settings.shared.langRawValue]), boldStrings: R.string.localizable.onboardingAirBillInfoStringsBolds(preferredLanguages: [Settings.shared.langRawValue]), color: R.color.airbillGreenOnboarding()!, buttonText: R.string.localizable.onboardingNext(preferredLanguages: [Settings.shared.langRawValue])),
            
            OnboardingItemModel(image: R.image.picturesOnboarding()!,
                                title: R.string.localizable.onboardingStep1(preferredLanguages: [Settings.shared.langRawValue]),
                                text: R.string.localizable.onboardingStep1Info(preferredLanguages: [Settings.shared.langRawValue]), boldStrings: R.string.localizable.onboardingStep1StringsBolds(preferredLanguages: [Settings.shared.langRawValue]), color: R.color.picturesGreenOnboarding()!, buttonText: R.string.localizable.onboardingNext(preferredLanguages: [Settings.shared.langRawValue])),
            
            OnboardingItemModel(image: R.image.actionOnboarding()!,
                                title: R.string.localizable.onboardingStep2(preferredLanguages: [Settings.shared.langRawValue]),
                                text: R.string.localizable.onboardingStep2Info(preferredLanguages: [Settings.shared.langRawValue]), boldStrings: R.string.localizable.onboardingStep2StringsBolds(preferredLanguages: [Settings.shared.langRawValue]), color: R.color.actionOrangeOnboarding()!, buttonText: R.string.localizable.onboardingNext(preferredLanguages: [Settings.shared.langRawValue])),
            
            OnboardingItemModel(image: R.image.folderOnboarding()!,
                                title: R.string.localizable.onboardingStep3(preferredLanguages: [Settings.shared.langRawValue]),
                                text: R.string.localizable.onboardingStep3Info(preferredLanguages: [Settings.shared.langRawValue]), boldStrings: R.string.localizable.onboardingStep3StringsBolds(preferredLanguages: [Settings.shared.langRawValue]), color: R.color.foldersGreenOnboarding()!, buttonText: R.string.localizable.onboardingNext(preferredLanguages: [Settings.shared.langRawValue])),
            
            OnboardingItemModel(image: R.image.shareOnboarding()!,
                                title: R.string.localizable.onboardingStep4(preferredLanguages: [Settings.shared.langRawValue]),
                                text: R.string.localizable.onboardingStep4Info(preferredLanguages: [Settings.shared.langRawValue]), boldStrings: R.string.localizable.onboardingStep4StringsBolds(preferredLanguages: [Settings.shared.langRawValue]), color: R.color.shareGreenOnboarding()!, buttonText: R.string.localizable.onboardingLetsStart(preferredLanguages: [Settings.shared.langRawValue])),
        ]
    }
}
