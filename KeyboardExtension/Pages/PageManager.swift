//
//  PageManager.swift
//  KeyboardExtension
//
//  Manages page navigation
//

import UIKit

protocol PageManagerDelegate: AnyObject {
    func pageManager(_ manager: PageManager, didRequestNavigateTo page: PageState)
}

final class PageManager {

    weak var delegate: PageManagerDelegate?

    private(set) var currentPage: PageState = .home
    private weak var containerView: UIView?

    // Pages
    private let homePage: KeyboardControlsView
    private let askAIPage: AskAIView
    private let responsePage: ImproveWritingView

    init(homePage: KeyboardControlsView, askAIPage: AskAIView, responsePage: ImproveWritingView) {
        self.homePage = homePage
        self.askAIPage = askAIPage
        self.responsePage = responsePage
    }

    func setup(in containerView: UIView) {
        self.containerView = containerView
        showPage(.home, animated: false)
    }

    func showPage(_ page: PageState, animated: Bool = true) {
        guard let container = containerView else { return }

        currentPage = page

        // Get the view for the new page
        let newView: UIView
        switch page {
        case .home:
            newView = homePage
        case .askAIInput:
            newView = askAIPage
            askAIPage.clearQuestion()
        case .response(let type):
            newView = responsePage
            responsePage.setHeaderTitle(type.title)
            responsePage.clearText()
        }

        // Remove all current subviews
        container.subviews.forEach { $0.removeFromSuperview() }

        // Add new view with full constraints
        newView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(newView)

        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: container.topAnchor),
            newView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Animate if needed
        if animated {
            newView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                newView.alpha = 1
            }
        }
    }

    func navigateBack() {
        switch currentPage {
        case .home:
            break // Already at home
        case .askAIInput:
            showPage(.home)
        case .response:
            showPage(.home)
        }
    }
}
