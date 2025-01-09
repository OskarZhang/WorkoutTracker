//
//  LogWorkoutView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/27/24.
//

import UIKit

class SliderView: UIView {
    
    struct Config {
        var defaultValue: Int
        var numberOfItems: Int
        var unit: String
    }
    
    private var cellWidth: CGFloat {
        return collectionView.frame.width / CGFloat(config.numberOfItems)
    }
    
    private var numOfBufferCells: Int {
        return 4
    }
    
    private var page = 0
    private var layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
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
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        unitLabel.text = config.unit
        collectionView.register(SliderCell.self, forCellWithReuseIdentifier: "SliderCell")
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        addSubview(currentValueLabel)
        addSubview(centerPin)
        addSubview(unitLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: currentValueLabel.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            centerPin.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerPin.topAnchor.constraint(equalTo: currentValueLabel.bottomAnchor),
            centerPin.bottomAnchor.constraint(equalTo: bottomAnchor),
            currentValueLabel.topAnchor.constraint(equalTo: topAnchor),
            currentValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            unitLabel.centerYAnchor.constraint(equalTo: currentValueLabel.centerYAnchor),
            unitLabel.leadingAnchor.constraint(equalTo: currentValueLabel.trailingAnchor)
        ])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if (collectionView.contentInset.left <= 0) {
            collectionView.contentInset.left = collectionView.bounds.width / 2.0 - cellWidth / 2.0
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = (scrollView as? UICollectionView) else {
            return
        }
        if (collectionView.contentSize.width > 0) {
            var targetContentOffsetX: CGFloat = collectionView.contentOffset.x
            let viewWidth = collectionView.bounds.width / 2.0
            let contentWidth = collectionView.contentSize.width / 2.0
            
            // one page away and half a cell away, bump page up
            let nextPageOffsetThreshold = contentWidth - viewWidth - cellWidth / 2.0
            
            // about to hit 0.0 offset
            let previousPageOffsetThreshold = cellWidth / 2.0
            
            if (collectionView.contentOffset.x >= nextPageOffsetThreshold) {
                page += 1
                targetContentOffsetX = previousPageOffsetThreshold + collectionView.contentOffset.x - nextPageOffsetThreshold
                collectionView.contentOffset.x = targetContentOffsetX
            } else if (collectionView.contentOffset.x <= previousPageOffsetThreshold && page > 0) {
                page -= 1
                targetContentOffsetX = nextPageOffsetThreshold - (previousPageOffsetThreshold - collectionView.contentOffset.x)
                collectionView.contentOffset.x = targetContentOffsetX
            } else {
                targetContentOffsetX = collectionView.contentOffset.x
            }
            
            let realOffset = (nextPageOffsetThreshold - previousPageOffsetThreshold) * CGFloat(page)  + targetContentOffsetX
            let targetIndex = targetIndex(contentOffSetX: realOffset)
            currentValueLabel.text = "\(targetIndex)"
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        feedbackGenerator.impactOccurred(intensity: 0.5)
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
        let index = targetIndex(contentOffSetX: collectionView.contentOffset.x)
        let snappedContentOffsetX = (CGFloat(index) + 0.5) * cellWidth
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.collectionView.contentOffset.x = snappedContentOffsetX - (self?.collectionView.frame.width ?? 0.0) / 2.0
        }
        feedbackGenerator.impactOccurred(intensity: 1.0)
    }
   

    private func targetIndex(contentOffSetX: CGFloat) -> Int {
        // we are looking for where the center needle lands, this value should represent how far away the needle is from 0
        let centerXOffset = contentOffSetX + collectionView.frame.width / 2.0
        let cellWidth = collectionView.frame.width / CGFloat(config.numberOfItems)
        
        return Int(floor(centerXOffset / cellWidth))
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
