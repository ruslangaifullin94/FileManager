//
//  ViewController.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 04.07.2023.
//

import UIKit
import PhotosUI
import KeychainSwift

protocol ViewControllerDelegate: AnyObject {
    func reload()
}

class ViewController: UIViewController {
    
    var model: Model
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviewsAndConstraits()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        AlertNotification.shared.showPickerAddFolder(in: self, withTitle: "Создать папку?") { text in
            self.model.createFolder(name: text)
            self.tableView.reloadData()
        }
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
//            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadSections([0,0], with: .automatic)
            
        }
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if model.isPathForItemIsFolder(index: indexPath.row) {
            let model = Model(path: model.path + "/" + model.items[indexPath.row])
            let viewController = ViewController(model: model)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let detailViewController = DetailViewController(imageUrl: model.items[indexPath.row], path: model.path)
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var configForCell = UIListContentConfiguration.cell()
        configForCell.text = model.items[indexPath.row]
        if model.isPathForItemIsFolder(index: indexPath.row) {
            configForCell.image = UIImage(systemName: "folder.fill")
        }
        cell.accessoryType = model.isPathForItemIsFolder(index: indexPath.row) ? .disclosureIndicator : .none
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

extension ViewController: ViewControllerDelegate {
    func reload() {
        tableView.reloadData()
    }
}
