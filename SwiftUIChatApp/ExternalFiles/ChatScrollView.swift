//
//  TestView.swift
//  Infinity Protection Service
//
//  Created by differenz on 11/06/21.
//

import SwiftUI

struct ChatScrollView<Content: View>: View {

    var axis: Axis.Set
    var content: Content

    // init
    init(_ axis: Axis.Set = .horizontal, @ViewBuilder builder: ()->Content) {
        self.axis = axis
        self.content = builder()
    }

    //MARK: - Body
    var body: some View {
        GeometryReader { proxy in
           
            ScrollView(axis, showsIndicators: false) {
                Stack(axis) {
                    Spacer()
                    content
                }
                .frame(
                    minWidth: minWidth(in: proxy, for: axis),
                    minHeight: minHeight(in: proxy, for: axis)
                )
            }
        }
    }

    func minWidth(in proxy: GeometryProxy, for axis: Axis.Set) -> CGFloat? {
        axis.contains(.horizontal) ? proxy.size.width : nil
    }

    func minHeight(in proxy: GeometryProxy, for axis: Axis.Set) -> CGFloat? {
        axis.contains(.vertical) ? proxy.size.height : nil
    }
}

struct ChatScrollView_Previews: PreviewProvider {
    static var previews: some View {
        ChatScrollView(.vertical) {
            ForEach(0..<50) { item in
                Text("\(item)")
                    .padding()
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(6)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct Stack<Content: View>: View {
    var axis: Axis.Set
    var content: Content

    init(_ axis: Axis.Set = .vertical, @ViewBuilder builder: ()->Content) {
        self.axis = axis
        self.content = builder()
    }

    var body: some View {
        switch axis {
        case .horizontal:
            HStack {
                content
            }
        case .vertical:
            VStack {
                content
            }
        default:
            VStack {
                content
            }
        }
    }
}
