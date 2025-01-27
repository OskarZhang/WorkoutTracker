//
//  LogWorkoutView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/27/24.
//

import UIKit
import SwiftUI

protocol SliderViewDelegate: AnyObject {
    func valueDidChange(newValue: Int)
}

class SliderView: UIView {
    
    struct Config {
        var defaultValue: Int
        var numberOfItems: Int
        var unit: String
    }
    
    private var numOfBufferCells: Int {
        return 4
    }
    
    private var page = 0
    private var layout = UICollectionViewFlowLayout()
    private let infiniteScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let needleStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        
        return stack
    }()
    
    private var lastFrameContentOffsetX: CGFloat = 0.0
    
    private var realOffsetX: CGFloat = 0.0

    weak var delegate: SliderViewDelegate?
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var currentValue: Int = 0 {
        didSet {
            if (oldValue != currentValue) {
                feedbackGenerator.impactOccurred(intensity: 0.5)
                currentValueLabel.text = "\(currentValue)"
                debugPrint("contentOffSet \(infiniteScrollView.contentOffset.x.truncate(places: 2)) abs contentOffset \(realOffsetX.truncate(places: 2)) value \(currentValue)")
                delegate?.valueDidChange(newValue: currentValue)

            }
        }
    }
    

    private let currentValueLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let centerPin: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 2.0).isActive = true
        return view
    }()
    
    private var hasSetInitialPosition: Bool = false
    
    private var cellWidth: CGFloat {
        let width = infiniteScrollView.bounds.width / CGFloat(config.numberOfItems)
        return width
    }

    
    private let config: Config
    init(config: Config) {
        self.config = config
        super.init(frame: .zero)
        
        assert(config.numberOfItems % 2 != 0, "Please specify an odd number so the center needle can be perfectly.. centered")
        layout.scrollDirection = .horizontal
        
        
        currentValue = config.defaultValue
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        unitLabel.text = config.unit
        currentValueLabel.text = "\(currentValue)"
        
        infiniteScrollView.delegate = self

        
        
        // make x needles in stack
        for _ in 0..<config.numberOfItems * 3 {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = .clear
            
            let needle = UIView()
            needle.backgroundColor = .lightGray
            needle.translatesAutoresizingMaskIntoConstraints = false
            needle.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
            
            container.addSubview(needle)

            container.heightAnchor.constraint(equalTo: needle.heightAnchor).isActive = true
            container.centerXAnchor.constraint(equalTo: needle.centerXAnchor).isActive = true
                
            
            needleStackView.addArrangedSubview(container)
        }
        

        
        
        infiniteScrollView.addSubview(needleStackView)
        addSubview(infiniteScrollView)
        addSubview(currentValueLabel)
        addSubview(centerPin)
        addSubview(unitLabel)
        
        NSLayoutConstraint.activate([
            infiniteScrollView.topAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: 8.0),
            infiniteScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            infiniteScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infiniteScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            centerPin.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPin.topAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: 8.0),
            centerPin.bottomAnchor.constraint(equalTo: bottomAnchor),
            unitLabel.topAnchor.constraint(equalTo: topAnchor),
            currentValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            unitLabel.centerYAnchor.constraint(equalTo: currentValueLabel.centerYAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: currentValueLabel.trailingAnchor),
            // layout needle stack inside scrollview
            needleStackView.widthAnchor.constraint(equalTo: infiniteScrollView.widthAnchor, multiplier: 3.0),
            needleStackView.heightAnchor.constraint(equalTo: infiniteScrollView.heightAnchor),
            needleStackView.leadingAnchor.constraint(equalTo: infiniteScrollView.contentLayoutGuide.leadingAnchor),
            needleStackView.trailingAnchor.constraint(equalTo: infiniteScrollView.contentLayoutGuide.trailingAnchor),
            needleStackView.topAnchor.constraint(equalTo: infiniteScrollView.contentLayoutGuide.topAnchor)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasSetInitialPosition, infiniteScrollView.bounds.width > 0.0 {
            hasSetInitialPosition = true
            
            realOffsetX = CGFloat(currentValue) * cellWidth
            
            let contentOffsetX:CGFloat = realOffsetX.truncatingRemainder(dividingBy: infiniteScrollView.bounds.width)
            lastFrameContentOffsetX = contentOffsetX
            infiniteScrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0.0), animated: false)
        }
    }

    func updateValue(value: Int) {
        if (currentValue == value) {
            return
        }
        currentValue = value
        realOffsetX = CGFloat(currentValue) * cellWidth
        
        let contentOffsetX:CGFloat = realOffsetX.truncatingRemainder(dividingBy: infiniteScrollView.bounds.width)
        lastFrameContentOffsetX = contentOffsetX
        infiniteScrollView.setContentOffset(CGPoint(x: contentOffsetX, y: 0.0), animated: false)

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentSize.width <= 0) {
            return
        }
        
        realOffsetX += (scrollView.contentOffset.x - lastFrameContentOffsetX)
        
        // 0.5 is half of the width for the center needle
        currentValue = max(0, Int(floor((realOffsetX + 0.5) / cellWidth)))
        
        if (realOffsetX <= 0.0) {
                lastFrameContentOffsetX = 0.0
                realOffsetX = 0.0
            
            if scrollView.contentOffset.x < 0.0 {
                UIView.animate(withDuration: 0.3) {
                    // snap it back to 0
                    scrollView.contentOffset.x = 0.0
                }
            } else {
                scrollView.contentOffset.x = 0.0
            }
            
            return
        }
        
        let contentWidth = scrollView.contentSize.width
        let offsetX = scrollView.contentOffset.x
        
        if offsetX < (contentWidth / 3) - (scrollView.bounds.width / 2),
           currentValue >= config.numberOfItems / 2 {
            lastFrameContentOffsetX = offsetX + (contentWidth / 3)

            scrollView.contentOffset = CGPoint(x: offsetX + (contentWidth / 3), y: scrollView.contentOffset.y)
        } else if offsetX > (2 * contentWidth / 3) - (scrollView.bounds.width / 2)
        {
            lastFrameContentOffsetX = offsetX - (contentWidth / 3)
            scrollView.contentOffset = CGPoint(x: offsetX - (contentWidth / 3), y: scrollView.contentOffset.y)
        } else {
            lastFrameContentOffsetX = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapIntoPlace()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            snapIntoPlace()
        }
    }
    
    private func snapIntoPlace() {
        let cellWidth = cellWidth
        let snappedValue = Int(floor(realOffsetX / cellWidth + 0.5))
        let newRealOffsetX = CGFloat(snappedValue) * cellWidth
        let offsetDelta = newRealOffsetX - realOffsetX
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.infiniteScrollView.contentOffset.x += offsetDelta
        } completion: { [weak self] completed in
            if (completed) {
                self?.feedbackGenerator.impactOccurred(intensity: 1.0)
            }
        }
    }
}


extension SliderView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return config.numberOfItems + numOfBufferCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCell", for: indexPath) as! SliderCell
        return cell
    }
    
}

extension SliderView {
    struct Representable: UIViewRepresentable {
        
        class Coordinator: NSObject, SliderViewDelegate {
            var parent: Representable
            
            init(_ parent: Representable) {
                self.parent = parent
            }
            
            func valueDidChange(newValue: Int) {
                self.parent.value = newValue
            }
        }
        
        @Binding var value: Int
        
        func makeUIView(context: Context) -> SliderView {
            let slider = SliderView(config: .init(defaultValue: value, numberOfItems: 19, unit: "kg"))
            slider.delegate = context.coordinator
            return slider
        }
        func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
            return nil
        }
        
        func updateUIView(_ uiView: SliderView, context: Context) {
            uiView.updateValue(value: value)
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
    }
}
private class SliderCell: UICollectionViewCell {
    
    private let lineView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lineView)
        lineView.backgroundColor = .lightGray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(x: bounds.width / 2.0 - 1.0, y: 0, width: 1, height: bounds.height)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

extension CGFloat {
    func truncate(places : Int)-> CGFloat {
        return CGFloat(floor(pow(10.0, CGFloat(places)) * self)/pow(10.0, CGFloat(places)))
    }
}
