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
    
//    private var cellWidth: CGFloat {
//        return collectionView.frame.width / CGFloat(config.numberOfItems)
//    }
    
    private var numOfBufferCells: Int {
        return 4
    }
    
    private var page = 0
    private var layout = UICollectionViewFlowLayout()
//    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        return stack
    }()
    
    private var lastFrameContentOffset: CGPoint?
    weak var delegate: SliderViewDelegate?
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var currentValue: Int = 0 {
        didSet {
            if (oldValue != currentValue) {
                if (abs(oldValue - currentValue) != 1) {
                    debugPrint("new value \(currentValue) old val \(oldValue)")
                }
                feedbackGenerator.impactOccurred(intensity: 0.5)
            }
            currentValueLabel.text = "\(currentValue)"
            delegate?.valueDidChange(newValue: currentValue)
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
    
    private let config: Config
    init(config: Config) {
        self.config = config
        super.init(frame: .zero)
        
        layout.scrollDirection = .horizontal
        
        
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        unitLabel.text = config.unit
        
        
        infiniteScrollView.delegate = self

        
        
        // make x needles in stack
        for _ in 0..<config.numberOfItems * 2 {
            let needle = UIView()
            needle.backgroundColor = .lightGray
            needle.translatesAutoresizingMaskIntoConstraints = false
            needle.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
            needleStackView.addArrangedSubview(needle)
        }
        
        
        infiniteScrollView.addSubview(needleStackView)
        addSubview(infiniteScrollView)
        addSubview(currentValueLabel)
        addSubview(centerPin)
        addSubview(unitLabel)
        
        NSLayoutConstraint.activate([
            infiniteScrollView.topAnchor.constraint(equalTo: unitLabel.bottomAnchor, constant: 10),
            infiniteScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            infiniteScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infiniteScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            centerPin.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPin.topAnchor.constraint(equalTo: unitLabel.bottomAnchor),
            centerPin.bottomAnchor.constraint(equalTo: bottomAnchor),
            unitLabel.topAnchor.constraint(equalTo: topAnchor),
            currentValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            unitLabel.centerYAnchor.constraint(equalTo: currentValueLabel.centerYAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: currentValueLabel.trailingAnchor),
            // layout needle stack inside scrollview
            needleStackView.widthAnchor.constraint(equalTo: infiniteScrollView.widthAnchor, multiplier: 2.0),
            needleStackView.heightAnchor.constraint(equalTo: infiniteScrollView.heightAnchor),
            needleStackView.leadingAnchor.constraint(equalTo: infiniteScrollView.contentLayoutGuide.leadingAnchor),
            needleStackView.trailingAnchor.constraint(equalTo: infiniteScrollView.contentLayoutGuide.trailingAnchor),
            needleStackView.topAnchor.constraint(equalTo: infiniteScrollView.contentLayoutGuide.topAnchor)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if (infiniteScrollView.contentInset.left <= 0) {
            infiniteScrollView.contentInset.left = infiniteScrollView.bounds.width / 2.0

        }
        
    }



    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // in overscroll buffer zone
        if (scrollView.contentSize.width <= 0) {
            return
        }
        let leadingInset = scrollView.contentInset.left
        let normalizedOffsetX = scrollView.contentOffset.x + leadingInset
        
        
        // calculate if we passed a needle
        // there are x needles, and (x - 1) space between needles
        // total width is scrollView.contentSize
        // find whether there exists a needle between [lastX, currentX]
        
        // remove the first or last needle from calculation
        let cellWidth = (scrollView.contentSize.width - 1.0) / (CGFloat(config.numberOfItems) * 2.0 - 1)

        if let lastX = lastFrameContentOffset?.x
        {
            
            if (lastX < scrollView.contentOffset.x) {
                // going to the right, use floor
                let oldNeedleIndex = floor((lastX + leadingInset) / cellWidth)
                let newNeedleIndex = floor(normalizedOffsetX / cellWidth)
                
                if (oldNeedleIndex < 0) {
                    // means we overscrolled
                    currentValue = 0
                } else if (newNeedleIndex > oldNeedleIndex) {
                    currentValue += Int(newNeedleIndex - oldNeedleIndex)
                }
            } else if (lastX > scrollView.contentOffset.x) {
                // going to the left, use ceil
                let oldNeedleIndex = ceil((lastX + leadingInset) / cellWidth)
                let newNeedleIndex = ceil(normalizedOffsetX / cellWidth)
                
                if (oldNeedleIndex > newNeedleIndex) {
                    currentValue = max(0, currentValue - Int(oldNeedleIndex) + Int(newNeedleIndex))
                }
            }
            
        }
        lastFrameContentOffset = scrollView.contentOffset

        if (currentValue < config.numberOfItems / 2 ) {
            return
        }
 
        // over/underflow adjustment
        
        let maxX = scrollView.contentSize.width - leadingInset
        
        let minX = leadingInset
        
        if (normalizedOffsetX >= maxX) {
            lastFrameContentOffset?.x = (normalizedOffsetX - maxX)
            scrollView.contentOffset.x = (normalizedOffsetX - maxX)
            
        } else if (normalizedOffsetX <= minX) {
            lastFrameContentOffset?.x = leadingInset - (minX - normalizedOffsetX)
            scrollView.contentOffset.x = leadingInset - (minX - normalizedOffsetX)
        }
        

    }
    
//        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//            snapIntoPlace()
//        }
//    
//    
//        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//            if (!decelerate) {
//                snapIntoPlace()
//            }
//        }
    
        private func snapIntoPlace() {
            
            let leadingInset = infiniteScrollView.contentInset.left
            let normalizedOffsetX = infiniteScrollView.contentOffset.x + leadingInset
            let cellWidth = (infiniteScrollView.contentSize.width - 1.0) / (CGFloat(config.numberOfItems) * 2.0 - 1)
            
            let newContentOffset: CGFloat
            if (currentValue >= config.numberOfItems / 2) {
                // eg. 10 - 20 / 2 + 1 = 1, 1% 20 = 1
                let contentOffsetIndex = (currentValue - config.numberOfItems / 2 + 1) % 20
                newContentOffset = floor(normalizedOffsetX / cellWidth) * cellWidth - leadingInset
                
                var calculatedWrong = CGFloat(contentOffsetIndex + config.numberOfItems / 2 - 1) * cellWidth - leadingInset
                
                
                debugPrint("snapping difference \(currentValue): wrong \(contentOffsetIndex) correct \(floor(normalizedOffsetX / cellWidth))")
            } else {
                newContentOffset = CGFloat(currentValue) * cellWidth - leadingInset
            }
            
            lastFrameContentOffset = infiniteScrollView.contentOffset
            
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.infiniteScrollView.contentOffset.x = newContentOffset
            }
        }
    
    
}

//extension SliderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: cellWidth, height: collectionView.frame.height)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return .zero
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard let collectionView = (scrollView as? UICollectionView) else {
//            return
//        }
//        if (collectionView.contentSize.width > 0) {
//            var targetContentOffsetX: CGFloat = collectionView.contentOffset.x
//            let viewWidth = collectionView.bounds.width / 2.0
//            let contentWidth = collectionView.contentSize.width / 2.0
//            
//            // one page away and half a cell away, bump page up
//            let nextPageOffsetThreshold = contentWidth - viewWidth - cellWidth / 2.0
//            
//            // about to hit 0.0 offset
//            let previousPageOffsetThreshold = cellWidth / 2.0
//            
//            if (collectionView.contentOffset.x >= nextPageOffsetThreshold) {
//                page += 1
//                targetContentOffsetX = previousPageOffsetThreshold + collectionView.contentOffset.x - nextPageOffsetThreshold
//                collectionView.contentOffset.x = targetContentOffsetX
//            } else if (collectionView.contentOffset.x <= previousPageOffsetThreshold && page > 0) {
//                page -= 1
//                targetContentOffsetX = nextPageOffsetThreshold - (previousPageOffsetThreshold - collectionView.contentOffset.x)
//                collectionView.contentOffset.x = targetContentOffsetX
//            } else {
//                targetContentOffsetX = collectionView.contentOffset.x
//            }
//            
//            let realOffset = (nextPageOffsetThreshold - previousPageOffsetThreshold) * CGFloat(page)  + targetContentOffsetX
//            let targetIndex = targetIndex(contentOffSetX: realOffset)
//            if (targetIndex >= 0) {
//                currentValue = targetIndex
//            }
//            
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        feedbackGenerator.impactOccurred(intensity: 0.5)
//    }
//    
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        snapIntoPlace()
//    }
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if (!decelerate) {
//            snapIntoPlace()
//        }
//    }
//    
//    private func snapIntoPlace() {
//        let index = targetIndex(contentOffSetX: collectionView.contentOffset.x)
//        let snappedContentOffsetX = (CGFloat(index) + 0.5) * cellWidth
//        UIView.animate(withDuration: 0.2) { [weak self] in
//            self?.collectionView.contentOffset.x = snappedContentOffsetX - (self?.collectionView.frame.width ?? 0.0) / 2.0
//        }
//        feedbackGenerator.impactOccurred(intensity: 1.0)
//    }
//   
//
//    private func targetIndex(contentOffSetX: CGFloat) -> Int {
//        // we are looking for where the center needle lands, this value should represent how far away the needle is from 0
//        let centerXOffset = contentOffSetX + collectionView.frame.width / 2.0
//        let cellWidth = collectionView.frame.width / CGFloat(config.numberOfItems)
//
//        return Int(floor(centerXOffset / cellWidth))
//    }
//}

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
            let slider = SliderView(config: .init(defaultValue: 35, numberOfItems: 20, unit: "kg"))
            slider.delegate = context.coordinator
            return slider
        }
        func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
            return nil
        }
        
        func updateUIView(_ uiView: SliderView, context: Context) {
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
