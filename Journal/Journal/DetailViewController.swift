//
//  DetailViewController.swift
//  Journal
//
//  Created by Anıl Aygün on 23.12.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var fileName: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var caption: UILabel!
    
    
    var selectedImage : String?
    var selectedCaption : String?
    var selectedPath: URL!
    var picture : Picture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
            if let imageToload = selectedImage {
            fileName.text = imageToload
            image.image = UIImage(contentsOfFile: selectedPath.path)
            caption.text = selectedCaption
        }
        
        let defaults = UserDefaults.standard
        
        if let data = defaults.object(forKey:"name") as? Data{
            let decoder = JSONDecoder()
            do{
                picture?.fileName = try decoder.decode(String.self, from: data)
            }
            catch{
                print("Error decoding")
            }
            
        }
        
            
        
       
    }

    @objc func edit() {
        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        
        // File name text field
        alert.addTextField { textField in
            textField.placeholder = "New File Name"
        }
        
        // Caption text field
        alert.addTextField { textField in
            textField.placeholder = "New Caption"
            
        }
        
        let editAction = UIAlertAction(title: "Save Changes", style: .default) { [weak self, weak alert] _ in
            guard let newFileName = alert?.textFields?[0].text,
                  !newFileName.trimmingCharacters(in: .whitespaces).isEmpty,
                  let newCaption = alert?.textFields?[1].text,
                  !newCaption.trimmingCharacters(in: .whitespaces).isEmpty,
                  let picture = self?.picture else { return }
            
            let oldPath = self?.selectedPath
            let newPath = oldPath?.deletingLastPathComponent().appendingPathComponent(newFileName)
            
            // Move the file to the new path if the file name changed
            do {
                if let oldPath = oldPath, let newPath = newPath, newFileName != picture.fileName {
                    try FileManager.default.moveItem(at: oldPath, to: newPath)
                    picture.fileName = newFileName
                    self?.selectedPath = newPath
                }
            } catch {
                print("Error moving file: \(error)")
                return
            }
            
            // Update the caption
            picture.caption = newCaption
            
            // Update UI
            self?.fileName.text = newFileName
            self?.caption.text = newCaption
            self?.image.image = UIImage(contentsOfFile: self?.selectedPath.path ?? "")
            
            // Notify parent view controller to update
            if let parentVC = self?.navigationController?.viewControllers.first as? ViewController {
                parentVC.updatePicture(picture)
            }
            
            self?.save()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }


    
    func save() {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(picture?.fileName) {
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "name")
        }
        else {
            print("Error encoding")
        }
        
    }
    
    
}
