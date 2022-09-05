//
//  AppLifeCycleModifier.swift
//  SwiftUI_Practice
//
//  Created by hosoda-hiroshi on 2022/05/21.
//

import Foundation
import SwiftUI
import UIKit


/// Monitor and receive application life cycles,
/// inactive or active
struct AppLifeCycleModifier: ViewModifier {
    
    let active = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    let inactive = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
    
    private let action: (Bool) -> ()
    
    init(_ action: @escaping (Bool) -> ()) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear() /// `onReceive` will not work in the Modifier Without `onAppear`
            .onReceive(active, perform: { _ in
                action(true)
            })
            .onReceive(inactive, perform: { _ in
                action(false)
            })
    }
}

extension View {
    func onReceiveAppLifeCycle(perform action: @escaping (Bool) -> ()) -> some View {
        self.modifier(AppLifeCycleModifier(action))
    }
}
