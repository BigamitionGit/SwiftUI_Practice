//
//  SwiftUI_PracticeApp.swift
//  Shared
//
//  Created by hosoda-hiroshi on 2022/05/20.
//

import SwiftUI

@main
struct SwiftUI_PracticeApp: App {
    var body: some Scene {
        WindowGroup {
//            InfiniteCarousel(cards: [Card( { Color.red }), Card( { Color.blue }), Card( { Color.green }), Card( { Color.yellow }), Card( { Color.gray })])
            PopOverView()
        }
    }
}
