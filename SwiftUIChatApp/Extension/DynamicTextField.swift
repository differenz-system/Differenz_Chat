//
//  DynamicTextField.swift
//  SwiftUIChatApp
//
//  Created by differenz147 on 13/07/21.
//

import Foundation
import SwiftUI

struct DynamicHeightTextField: UIViewRepresentable {
    //MARK: - Variable
    @Binding var text: String

    //MARK: - makeUI
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true

        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.keyboardType = .asciiCapable

        context.coordinator.textView = textView
        textView.delegate = context.coordinator
        textView.layoutManager.delegate = context.coordinator

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(dynamicSizeTextField: self)
    }
}

class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {

    var dynamicHeightTextField: DynamicHeightTextField

    weak var textView: UITextView?

    init(dynamicSizeTextField: DynamicHeightTextField) {
        self.dynamicHeightTextField = dynamicSizeTextField
    }

    func textViewDidChange(_ textView: UITextView) {
        self.dynamicHeightTextField.text = textView.text
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        return true
    }


}
