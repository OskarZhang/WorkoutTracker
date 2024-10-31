//
//  InputViewController.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 10/27/24.
//

import UIKit
import SwiftUI

class InputViewController: UIViewController {
    
    private let mainView = InputView()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mainView)

        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mainView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        mainView.translatesAutoresizingMaskIntoConstraints = false
    }

}

struct Representable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> InputViewController {
        return InputViewController()
    }
    
    func updateUIViewController(_ uiViewController: InputViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = InputViewController
    
    
}
