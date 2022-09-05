//
//  PopOverView.swift
//  SwiftUI_Practice (iOS)
//
//  Created by hosoda-hiroshi on 2022/06/17.
//

import SwiftUI

struct PopOverView: View {
    @State var isShow = false
    var body: some View {
        Button(action: {
            isShow.toggle()
        }) {
            Text("test")
        }
        .popover(isPresented: $isShow, attachmentAnchor: .point(.top), arrowEdge: .top) {
            Text("test2")
        }
    }
}

struct PopOverView_Previews: PreviewProvider {
    static var previews: some View {
        PopOverView()
    }
}
