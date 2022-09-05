//
//  BannerViewModel.swift
//  SwiftUI_Practice (iOS)
//
//  Created by hosoda-hiroshi on 2022/05/23.
//

import Foundation
import SwiftUI

fileprivate var _isAnimatedOffset: Bool = true

class BannerViewModel<Data, ID>: ObservableObject where Data : RandomAccessCollection, ID : Hashable {
    
    /// external index
    @Binding
    private var index: Int
    
    private let _data: Data
    private let _dataId: KeyPath<Data.Element, ID>
    private let _spacing: CGFloat
    private let _headspace: CGFloat
    private let _autoScroll: AutoScrollStatus
    
    init(_ data: Data, id: KeyPath<Data.Element, ID>, index: Binding<Int>, spacing: CGFloat, headspace: CGFloat, autoScroll: AutoScrollStatus) {
        
        self._data = data
        self._dataId = id
        self._spacing = spacing
        self._headspace = headspace
        self._autoScroll = autoScroll
        
        if data.count > 1 {
            activeIndex = index.wrappedValue + 1
        } else {
            activeIndex = index.wrappedValue
        }
        
        self._index = index
    }
    
    /// The index of the currently active subview.
    @Published var activeIndex: Int = 0 {
        willSet {
            if isWrap {
                if newValue > _data.count || newValue == 0 {
                    return
                }
                index = newValue - 1
            } else {
                index = newValue
            }
        }
        didSet {
            changeOffset()
        }
    }
    
    /// Offset x of the view drag.
    @Published var dragOffset: CGFloat = .zero
    
    /// size of GeometryProxy
    var viewSize: CGSize = .zero
    
    
    /// Counting of time
    /// work when `isTimerActive` is true
    /// Toggles the active subviewview and resets if the count is the same as
    /// the duration of the auto scroll. Otherwise, increment one
    private var timing: TimeInterval = 0
    
    /// Define listen to the timer
    /// Ignores listen while dragging, and listen again after the drag is over
    /// Ignores listen when App will resign active, and listen again when it become active
    private var isTimerActive = true
    func setTimerActive(_ active: Bool) {
        isTimerActive = active
    }
    
}


extension BannerViewModel {
    
    var data: Data {
        guard _data.count != 0 else {
            return _data
        }
        guard _data.count > 1 else {
            return _data
        }
        return [_data.last!] + _data + [_data.first!] as! Data
    }
    
    var dataId: KeyPath<Data.Element, ID> {
        return _dataId
    }
    
    var spacing: CGFloat {
        return _spacing
    }
    
    var offsetAnimation: Animation? {
        guard isWrap else {
            return .spring()
        }
        return _isAnimatedOffset ? .spring() : .none
    }
    
    var itemWidth: CGFloat {
        max(0, viewSize.width - defaultPadding * 2)
    }
    
    var timer: TimePublisher? {
        guard autoScroll.isActive else {
            return nil
        }
        return Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}

// MARK: - private variable
extension BannerViewModel {
    
    private var isWrap: Bool {
        return _data.count > 1
    }
    
    private var autoScroll: AutoScrollStatus {
        guard _data.count > 1 else { return .inactive }
        guard case let .active(t) = _autoScroll else { return _autoScroll }
        return t > 0 ? _autoScroll : .inactive
    }
    
    private var defaultPadding: CGFloat {
        return (_headspace + spacing)
    }
    
    private var itemActualWidth: CGFloat {
        itemWidth + spacing
    }
}

// MARK: - Offset Method
extension BannerViewModel {
    /// current offset value
    var offset: CGFloat {
        let activeOffset = CGFloat(activeIndex) * itemActualWidth
        return defaultPadding - activeOffset + dragOffset
    }
    
    /// change offset when acitveItem changes
    private func changeOffset() {
        _isAnimatedOffset = true
        guard isWrap else {
            return
        }
        
        let minimumOffset = defaultPadding
        let maxinumOffset = defaultPadding - CGFloat(data.count - 1) * itemActualWidth
        
        if offset == minimumOffset {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.activeIndex = self.data.count - 2
                _isAnimatedOffset = false
            }
        } else if offset == maxinumOffset {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.activeIndex = 1
                _isAnimatedOffset = false
            }
        }
    }
}

// MARK: - Drag Gesture
extension BannerViewModel {
    /// drag gesture of view
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged(dragChanged)
            .onEnded(dragEnded)
    }
    
    private func dragChanged(_ value: DragGesture.Value) {
        
        _isAnimatedOffset = true
        
        /// Defines the maximum value of the drag
        /// Avoid dragging more than the values of multiple subviews at the end of the drag,
        /// and still only one subview is toggled
        var offset: CGFloat = itemActualWidth
        if value.translation.width > 0 {
            offset = min(offset, value.translation.width)
        } else {
            offset = max(-offset, value.translation.width)
        }
        
        /// set drag offset
        dragOffset = offset
        
        /// stop active timer
        isTimerActive = false
    }
    
    private func dragEnded(_ value: DragGesture.Value) {
        /// reset drag offset
        dragOffset = .zero
        
        /// reset timing and restart active timer
        resetTiming()
        isTimerActive = true
        
        /// Defines the drag threshold
        /// At the end of the drag, if the drag value exceeds the drag threshold,
        /// the active view will be toggled
        /// default is one third of subview
        let dragThreshold: CGFloat = itemWidth / 3
        
        var activeIndex = self.activeIndex
        if value.translation.width > dragThreshold {
            activeIndex -= 1
        }
        if value.translation.width < -dragThreshold {
            activeIndex += 1
        }
        self.activeIndex = max(0, min(activeIndex, data.count - 1))
    }
}

// MARK: - Receive Timer
extension BannerViewModel {
    
    /// timer change
    func receiveTimer(_ value: Timer.TimerPublisher.Output) {
        /// Ignores listen when `isTimerActive` is false.
        guard isTimerActive else {
            return
        }
        /// increments of one and compare to the scrolling duration
        /// return when timing less than duration
        activeTiming()
        timing += 1
        if timing < autoScroll.interval {
            return
        }
        
        if activeIndex == data.count - 1 {
            /// `isWrap` is false.
            /// Revert to the first view after scrolling to the last view
            activeIndex = 0
        } else {
            /// `isWrap` is true.
            /// Incremental, calculation of offset by `offsetChanged(_: proxy:)`
            activeIndex += 1
        }
        resetTiming()
    }
    
    
    /// reset counting of time
    private func resetTiming() {
        timing = 0
    }
    
    /// time increments of one
    private func activeTiming() {
        timing += 1
    }
}


//private extension UserDefaults {
//
//    private struct Keys {
//        static let isAnimatedOffset = "isAnimatedOffset"
//    }
//
//    static var isAnimatedOffset: Bool {
//        get {
//            return UserDefaults.standard.bool(forKey: Keys.isAnimatedOffset)
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: Keys.isAnimatedOffset)
//        }
//    }
//}
