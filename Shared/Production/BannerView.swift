//
//  BannerView.swift
//  SwiftUI_Practice (iOS)
//
//  Created by hosoda-hiroshi on 2022/05/23.
//

import Foundation
import SwiftUI
import Combine

public struct BannerView<Data, ID, Content> : View where Data : RandomAccessCollection, ID : Hashable, Content : View {
    
    @ObservedObject
    private var viewModel: BannerViewModel<Data, ID>
    private let content: (Data.Element) -> Content
    
    public var body: some View {
        GeometryReader { proxy -> AnyView in
            viewModel.viewSize = proxy.size
            return AnyView(generateContent(proxy: proxy))
        }.clipped()
        bannerIndicater()
    }
    
    private func generateContent(proxy: GeometryProxy) -> some View {
        HStack(spacing: viewModel.spacing) {
            ForEach(viewModel.data, id: viewModel.dataId) {
                content($0)
                    .frame(width: viewModel.itemWidth)
                    .scaleEffect(x: 1, y: 1, anchor: .center)
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
        .offset(x: viewModel.offset)
        .gesture(viewModel.dragGesture)
        .animation(viewModel.offsetAnimation, value: viewModel.offset)
        .onReceive(timer: viewModel.timer, perform: viewModel.receiveTimer)
        .onReceiveAppLifeCycle(perform: viewModel.setTimerActive)
    }
}


// MARK: - Initializers
extension BannerView {
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, index: Binding<Int> = .constant(0), spacing: CGFloat = 10, headspace: CGFloat = 10, autoScroll: AutoScrollStatus = .inactive, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        
        self.viewModel = BannerViewModel(data, id: id, index: index, spacing: spacing, headspace: headspace, autoScroll: autoScroll)
        self.content = content
    }
    
}

extension BannerView {
    private func bannerIndicater() -> some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0 ..< self.viewModel.data.count - 2) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(index + 1 == viewModel.activeIndex ? Color.yellow : Color.gray)
                    .frame(width: 10, height: 4)
            }
        }
    }
}


//@available(iOS 14.0, OSX 11.0, *)
//struct ACarousel_LibraryContent: LibraryContentProvider {
//    let Datas = Array(repeating: _Item(color: .red), count: 3)
//    @LibraryContentBuilder
//    var views: [LibraryItem] {
//        LibraryItem(ACarousel(Datas) { _ in }, title: "ACarousel", category: .control)
//        LibraryItem(ACarousel(Datas, index: .constant(0), spacing: 10, headspace: 10, sidesScaling: 0.8, isWrap: false, autoScroll: .inactive) { _ in }, title: "ACarousel full parameters", category: .control)
//    }
//
//    struct _Item: Identifiable {
//        let id = UUID()
//        let color: Color
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
