//
//  ViewController.swift
//  Journal
//
//  Created by Anıl Aygün on 23.12.2024.
//

import UIKit

class ViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var pictures =  [Picture]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Journal"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPicture))
        
        let defaults = UserDefaults.standard
        if let picturesData = defaults.object(forKey: "pictures") as? Data{
            let decoder = JSONDecoder()
            do {
                pictures = try decoder.decode([Picture].self, from: picturesData)
            } catch {
                print("Error decoding pictures: \(error)")
            }
            
        }
    }

    @objc func addNewPicture() {
        let alert = UIAlertController(title: "Add Picture", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                self.showImagePicker(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in
                self.showImagePicker(sourceType: .photoLibrary)
            }
            alert.addAction(libraryAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert,animated: true)
    }
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let fileName = UUID().uuidString
        let fileURL = getDocumentDirectory().appendingPathComponent(fileName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: fileURL)
        }
        let picture = Picture(fileName: fileName, caption: "Lorem Ipsum")
        
        
        
        
        pictures.append(picture)
        save()
        tableView.reloadData()
        dismiss(animated: true)
    }
    func save(){
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(pictures){
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: "pictures")
        }else {
            print("Error")
        }
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            vc.picture = pictures[indexPath.row]
            vc.selectedImage = pictures[indexPath.row].fileName
            vc.selectedCaption = pictures[indexPath.row].caption
            vc.selectedPath = getDocumentDirectory().appendingPathComponent(pictures[indexPath.row].fileName)
           
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    func updatePicture(_ updatedPicture: Picture) {
        if let index = pictures.firstIndex(where: { $0.fileName == updatedPicture.fileName }) {
            pictures[index] = updatedPicture
            save()
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture.fileName
        return cell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

}

