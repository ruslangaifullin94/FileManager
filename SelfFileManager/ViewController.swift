//
//  ViewController.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 04.07.2023.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    var model = Model(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviewsAndConstraits()
    }

    
    private func setupView() {
        title = model.title
        view.backgroundColor = .systemBackground
        let folderBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .done, target: self, action: #selector(addFolder))
        let imageBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle"), style: .done, target: self, action: #selector(addImage))
        
        navigationItem.rightBarButtonItems = [imageBarButtonItem, folderBarButtonItem]
    }
    
    private func setupSubviewsAndConstraits() {
        view.addSubview(tableView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),

        ])
    }
    
    private func showImagePicker() {
        DispatchQueue.main.async {
            var configForPicker = PHPickerConfiguration()
            configForPicker.selectionLimit = 1
            
            let pickerViewController = PHPickerViewController(configuration: configForPicker)
            pickerViewController.delegate = self
            self.present(pickerViewController, animated: true)
        }
    }
    
    private func checkPermission() {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    self.showImagePicker()
                } else {
return
                    
                }
            }
        } else if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            showImagePicker()
        } else {
            return
        }
    }
    
    @objc private func addFolder() {
        
    }

    @objc private func addImage() {
       checkPermission()
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.deleteItem(withPath: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var configForCell = UIListContentConfiguration.cell()
        configForCell.text = model.items[indexPath.row]
        
        cell.contentConfiguration = configForCell
        return cell
    }
    
    
}

//MARK: - PHPickerViewControllerDelegate

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        guard let imageData = image.jpegData(compressionQuality: 1) else {
                            print(error?.localizedDescription ?? "Something went wrong...")
                            return
                        }
                        self.model.addImage(image: imageData)
                        self.tableView.reloadData()
                        picker.dismiss(animated: true)
                    }
                }
            }
            
        }
    }
    
}
