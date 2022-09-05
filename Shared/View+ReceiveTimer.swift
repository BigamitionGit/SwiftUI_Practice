//
//  View+ReceiveTimer.swift
//  SwiftUI_Practice
//
//  Created by hosoda-hiroshi on 2022/05/21.
//

import Foundation
import SwiftUI
import Combine

typealias TimePublisher = Publishers.Autoconnect<Timer.TimerPublisher>

extension View {
    
    func onReceive(timer: TimePublisher?, perform action: @escaping (Timer.TimerPublisher.Output) -> Void) -> some View {
        Group {
            if let timer = timer {
                self.onReceive(timer, perform: { value in
                    action(value)
                })
            } else {
                self
            }
        }
    }
}
