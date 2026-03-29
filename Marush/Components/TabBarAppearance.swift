//
//  TabBarAppearance.swift
//  Marush
//
//  Created by s2s s2s on 01.02.2026.
//

import UIKit

extension UITabBarController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Configure tab bar appearance
        configureTabBarAppearance()
        
        // Update shadow
        updateTabBarShadow()
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarItemAppearance()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 12)!,
            .foregroundColor: UIColor(named: "ColorDark")!
        ]
        let attributesBold: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Bold", size: 12)!,
            .foregroundColor: UIColor(named: "ColorDark")!
        ]
        appearance.normal.titleTextAttributes = attributes
        appearance.selected.titleTextAttributes = attributesBold

        // Badge color
        let badgeColor = UIColor(named: "ColorPrimary") ?? UIColor.systemBlue
        let badgeTextAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        appearance.normal.badgeBackgroundColor = badgeColor
        appearance.selected.badgeBackgroundColor = badgeColor
        appearance.normal.badgeTextAttributes = badgeTextAttr
        appearance.selected.badgeTextAttributes = badgeTextAttr

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "CEF0F7") ?? .white

        // Remove default shadow and separator
        tabBarAppearance.shadowColor = .clear
        tabBarAppearance.shadowImage = UIImage()

        // Remove any background effects
        tabBarAppearance.backgroundEffect = nil

        tabBarAppearance.stackedLayoutAppearance = appearance
        tabBarAppearance.inlineLayoutAppearance = appearance
        tabBarAppearance.compactInlineLayoutAppearance = appearance

        self.tabBar.standardAppearance = tabBarAppearance

        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        
        self.tabBar.layer.masksToBounds = true
//        self.tabBar.layer.cornerRadius = 30
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func updateTabBarShadow() {
        let shadowIdentifier = "TabBarShadow1"
        
        // Remove existing shadow view
        view.subviews.first(where: { $0.accessibilityIdentifier == shadowIdentifier })?.removeFromSuperview()
        
        // Create new shadow view
        if let shadowView2 = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow2" }) {
            shadowView2.frame = tabBar.frame
        } else {
            let shadowView2 = UIView(frame: .zero)
            shadowView2.frame = tabBar.frame
            shadowView2.accessibilityIdentifier = "TabBarShadow2"
            shadowView2.backgroundColor = UIColor.white
            shadowView2.layer.cornerRadius = 30
            shadowView2.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            shadowView2.layer.masksToBounds = false
            // Use the custom color "ColorPrimary" for shadowColor
            if let colorPrimary = UIColor(named: "CEF0F7") {
                shadowView2.layer.shadowColor = colorPrimary.cgColor // Custom shadow color
            } else {
                // Fallback if the color is not found
                shadowView2.layer.shadowColor = UIColor.black.cgColor // Default shadow color
            }
            
            shadowView2.layer.shadowOffset = CGSize(width: 0.0, height: UIDevice.current.localizedModel == "iPad" ? -15 : -15)
            shadowView2.layer.shadowOpacity = 1
            shadowView2.layer.shadowRadius = 0
            view.addSubview(shadowView2)
            view.bringSubviewToFront(tabBar)
        }
    }
}
