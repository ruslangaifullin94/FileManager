//
//  Model.swift
//  SelfFileManager
//
//  Created by Руслан Гайфуллин on 05.07.2023.
//

import Foundation

final class Model {
    
    var path: String 
    
    var title: String {
        NSString(string: path).lastPathComponent
    }
    
    lazy var items: [String] = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
    
    init(path: String) {
        self.path = path
        checkSort()
       
    }
    
    private func checkSort() {
        if UserDefaults.standard.bool(forKey: "sort") {
            let sort = items.sorted(by: <)
            items = sort
        } else {
            let sort = items.sorted(by: >)
            items = sort
        }
    }
    
    func createFolder(name: String) {
        try? FileManager.default.createDirectory(atPath: path + "/" + name, withIntermediateDirectories: true)
        items = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        checkSort()
    }
    
    func addImage(image: Data) {
        print(path)
        let url = URL(string: path)?.appendingPathComponent("image\(items.endIndex + 1).jpg")
        FileManager.default.createFile(atPath: (url?.path())!, contents: image)
        items = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        checkSort()
       
    }
    
    func deleteItem(withPath index: Int) {
        let pathForDelete = path + "/" + items[index]
        try? FileManager.default.removeItem(atPath: pathForDelete)
        items = (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
        checkSort()
    }
    
    func isPathForItemIsFolder(index: Int) -> Bool {
        var objCBool: ObjCBool = .init(false)
        FileManager.default.fileExists(atPath: path + "/" + items[index], isDirectory: &objCBool)
        if objCBool.boolValue {
            return true
        } else {
            return false
        }
    }
    
    
}
