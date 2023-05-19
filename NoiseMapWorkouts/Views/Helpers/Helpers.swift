//
//  Helpers.swift
//  WorkoutsNoise
//
//  Created by Merlin Chlosta on 19.05.23.
//

import Foundation
import SwiftUI
import HealthKit

extension View {
    public func gradientForeground(gradient: LinearGradient) -> some View {
        self.overlay(gradient)
            .mask(self)
    }

    public func myGradient() -> some View {
        var grad1 = LinearGradient(gradient: .init(colors: Constants.defaultColors), startPoint: .bottomLeading, endPoint: .topTrailing)
        //var grad2 = LinearGradient(gradient: .init(colors: Constants.defaultColors), startPoint: .topTrailing, endPoint: .topLeading)
        return self.overlay(gradientForeground(gradient: grad1)).mask(self)
        //.overlay(gradientForeground(gradient: grad2)).mask(self)
    }
}

extension HKQuantity {
    func to_dba_spl() -> Double {
        return self.doubleValue(for: HKUnit.decibelAWeightedSoundPressureLevel())
    }
}

func onMain(_ block: @escaping ()->Void)
{
    if !Thread.current.isMainThread
    {
        DispatchQueue.main.async(execute: block)
    }
    else
    {
        block()
    }
}

// Source:
//
//  ViewExtensions.swift
//  AirGuard
//
//  Created by Leon Böttger on 02.05.22.
// 
extension String {
    
    /// Returns the localized version of the current string.
    func localized() -> String {
        let localizedString = NSLocalizedString(self, comment: "")
        return localizedString
    }
    
    @available(iOS 15.0, *)
    func localizedMarkdown() -> AttributedString {
        let localizedString = NSLocalizedString(self, comment: "")
        let attributedString = try? AttributedString(markdown: localizedString, options: AttributedString.MarkdownParsingOptions(
            allowsExtendedAttributes: true,
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible
        ))
        return attributedString ?? AttributedString(localizedString)
    }
}
