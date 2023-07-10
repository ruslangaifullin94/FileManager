//
//  DetailViewController.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 09.07.2023.
//

import Foundation
import UIKit

final class DetailViewController: UIViewController {
    
    let imageUrl: String
    let path: String
    
    private lazy var imageView = UIImageView(image: UIImage(contentsOfFile: "\(path + "/" + imageUrl)"))
    
    init(imageUrl: String, path: String) {
        self.imageUrl = imageUrl
        self.path = path
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(imageView)
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageView.isHidden = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        imageView.contentMode = .scaleAspectFill
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.isHidden = true
    }
    
    private func setupConstraits() {
        
    }
    
}
