//
//  OnboardingContentViewItem.swift
//  AnimatedPageView
//
//  Created by Alex K. on 21/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

open class OnboardingContentViewItem: UIView {

    public var descriptionBottomConstraint: NSLayoutConstraint?
    public var titleCenterConstraint: NSLayoutConstraint?
    public var informationImageWidthConstraint: NSLayoutConstraint?
    public var informationImageHeightConstraint: NSLayoutConstraint?
    
    open var imageView: UIImageView?
    open var titleLabel: UILabel?
    open var descriptionLabel: UILabel?
    open var descriptionSubtextsToActions: [String: () -> ()]?

    init(titlePadding: CGFloat, descriptionPadding: CGFloat) {
        super.init(frame: .zero)
        commonInit(titlePadding: titlePadding, descriptionPadding: descriptionPadding)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let view = view, let descriptionLabel = self.descriptionLabel, view == descriptionLabel {
            let convertedLocation = view.convert(point, from: self)
            self.tapAction(location: convertedLocation)
        }
        return self
    }
}

// MARK: public

extension OnboardingContentViewItem {

    class func itemOnView(_ view: UIView, titlePadding: CGFloat, descriptionPadding: CGFloat) -> OnboardingContentViewItem {
        let item = Init(OnboardingContentViewItem(titlePadding: titlePadding, descriptionPadding: descriptionPadding)) {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(item)

        // add constraints
        item >>>- {
            $0.attribute = .height
            $0.constant = 10000
            $0.relation = .lessThanOrEqual
            return
        }

        for attribute in [NSLayoutConstraint.Attribute.leading, NSLayoutConstraint.Attribute.trailing] {
            (view, item) >>>- {
                $0.attribute = attribute
                return
            }
        }

        for attribute in [NSLayoutConstraint.Attribute.centerX, NSLayoutConstraint.Attribute.centerY] {
            (view, item) >>>- {
                $0.attribute = attribute
                return
            }
        }

        return item
    }
}

// MARK: create

private extension OnboardingContentViewItem {

    func commonInit(titlePadding: CGFloat, descriptionPadding: CGFloat) {

        let titleLabel = createTitleLabel(self, padding: titlePadding)
        let descriptionLabel = createDescriptionLabel(self, padding: descriptionPadding)
        let imageView = createImage(self)

        // added constraints
        titleCenterConstraint = (self, titleLabel, imageView) >>>- {
            $0.attribute = .top
            $0.secondAttribute = .bottom
            $0.constant = 50
            return
        }
        (self, descriptionLabel, titleLabel) >>>- {
            $0.attribute = .top
            $0.secondAttribute = .bottom
            $0.constant = 10
            return
        }

        self.titleLabel = titleLabel
        self.descriptionLabel = descriptionLabel
        self.imageView = imageView

        isUserInteractionEnabled = true
    }

    func createTitleLabel(_ onView: UIView, padding: CGFloat) -> UILabel {
        let label = Init(createLabel()) {
            $0.font = UIFont(name: "Nunito-Bold", size: 36)
            $0.numberOfLines = 0
        }
        onView.addSubview(label)

        // add constraints
        label >>>- {
            $0.attribute = .height
            $0.constant = 10000
            $0.relation = .lessThanOrEqual
            return
        }

        for (attribute, constant) in [
            (NSLayoutConstraint.Attribute.leading, padding),
            (NSLayoutConstraint.Attribute.trailing, -padding)
            ] {
            (onView, label) >>>- {
                $0.attribute = attribute
                $0.constant = constant
                return
            }
        }
        
        return label
    }

    func createDescriptionLabel(_ onView: UIView, padding: CGFloat) -> UILabel {
        let label = Init(createLabel()) {
            $0.font = UIFont(name: "OpenSans-Regular", size: 14)
            $0.numberOfLines = 0
            $0.isUserInteractionEnabled = true
        }
        onView.addSubview(label)

        // add constraints
        label >>>- {
            $0.attribute = .height
            $0.constant = 10000
            $0.relation = .lessThanOrEqual
            return
        }

        for (attribute, constant) in [(NSLayoutConstraint.Attribute.leading, padding), (NSLayoutConstraint.Attribute.trailing, -padding)] {
            (onView, label) >>>- {
                $0.attribute = attribute
                $0.constant = constant
                return
            }
        }

        (onView, label) >>>- { $0.attribute = .centerX; return }
        descriptionBottomConstraint = (onView, label) >>>- { $0.attribute = .bottom; return }

        return label
    }

    func createLabel() -> UILabel {
        return Init(UILabel(frame: CGRect.zero)) {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .center
            $0.textColor = .white
        }
    }

    func createImage(_ onView: UIView) -> UIImageView {
        let imageView = Init(UIImageView(frame: CGRect.zero)) {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        onView.addSubview(imageView)

        // add constratints
        informationImageWidthConstraint = imageView >>>- {
            $0.attribute = NSLayoutConstraint.Attribute.width
            $0.constant = 188
            return
        }
        
        informationImageHeightConstraint = imageView >>>- {
            $0.attribute = NSLayoutConstraint.Attribute.height
            $0.constant = 188
            return
        }

        for attribute in [NSLayoutConstraint.Attribute.centerX, NSLayoutConstraint.Attribute.top] {
            (onView, imageView) >>>- { $0.attribute = attribute; return }
        }

        return imageView
    }

    // MARK: Actions

    func tapAction(location: CGPoint) {
        guard let label = self.descriptionLabel,
            let text = label.attributedText?.string as NSString?,
            let descriptionSubtextsToActions = self.descriptionSubtextsToActions else {
                return
        }
        for subtitlesToAction in descriptionSubtextsToActions {
            let range = text.range(of: subtitlesToAction.key)
            let index = label.indexOfAttributedTextCharacterAtPoint(point: location)

            if checkRange(range, contain: index) == true {
                subtitlesToAction.value()
                return
            }
        }
    }
}

// MARK: support code
// Source: https://www.codementor.io/@nguyentruongky/hyperlink-label-qv2k8rpk9

func checkRange(_ range: NSRange, contain index: Int) -> Bool {
    return index > range.location && index < range.location + range.length
}

extension UILabel {
    func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
}
