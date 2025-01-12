//
//  InputView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/27/24.
//

import UIKit
import SwiftUI

class InputView: UIView {
    
    
    private let stackView = UIStackView()
    private let sliderView = SliderView(config: .init(defaultValue: 35, numberOfItems: 20, unit: "kg"))
    private let titleLabel = UILabel()
    
    var currentValue: Int {
        return sliderView.currentValue
    }
    
    init() {
        super.init(frame: .zero)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        
        titleLabel.text = "Weight"
        stackView.addArrangedSubview(sliderView)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        let constraints: [NSLayoutConstraint] = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sliderView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct InputViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> InputView {
        return InputView()
    }
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        return nil
    }
    
    func updateUIView(_ uiView: InputView, context: Context) {
        
    }
}
