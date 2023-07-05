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
    
    var items: [String] {
        return (try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []
    }
    
    init(path: String) {
        self.path = path
    }
    
    func addImage(image: Data) {
        let url = URL(string: path)?.appendingPathComponent("image\(items.endIndex + 1).jpg")
        FileManager.default.createFile(atPath: (url?.path())!, contents: image)
    }
    
    func deleteItem(withPath index: Int) {
        let pathForDelete = path + "/" + items[index]
        try? FileManager.default.removeItem(atPath: pathForDelete)
    }
}
