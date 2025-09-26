//
//  ViewController.swift
//  WishListApp
//
//  Created by Nouf Alloboon on 26/10/1446 AH.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController, UITextFieldDelegate {
    
    struct Wish: Equatable {
        let id: String
        var text: String
    }
    
    @IBOutlet weak var wishTextField: UITextField!
    @IBOutlet weak var wishTableView: UITableView!
    
    let db = Firestore.firestore()
    var wishes: [Wish] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        wishTextField.delegate = self
        
        wishTableView.dataSource = self
        wishTableView.delegate = self
        loadWishes()
    }
    
    @IBAction func addButton(_ sender: Any) {
        guard let wish = wishTextField.text, !wish.isEmpty else {
            showAlert(title: "Alert", message: "Cannot be empty")
            return
        }
        
        let newWish = Wish(id: UUID().uuidString, text: wish)

        
        db.collection("wishes").document(newWish.id).setData(["text": wish, "timestamp": Timestamp()]) { err in
            if let error = err {
                    print("Saving error \(error.localizedDescription)")
                
                Haptics.error()
                self.showAlert(title: "Saving is failed", message: error.localizedDescription)
                
                if let index = self.wishes.firstIndex(where: { $0.id == newWish.id }) {
                        self.wishes.remove(at: index)
                        self.wishTableView.reloadData()
                    }
                } else {
                    print("Wish saved successfully")
                    
                    Haptics.success()
                    self.showToast("The wish added successfully")
                    
                    self.wishes.append(newWish)
                    self.wishTextField.text = ""
                    self.wishTableView.reloadData()
                }
            }
    }

    func loadWishes(){
        db.collection("wishes").order(by: "timestamp", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                print("Loading error \(error.localizedDescription)")
            } else {
                self.wishes = []
                
                guard let snapshot = snapshot else { return }
                for doc in snapshot.documents {
                        if let text = doc["text"] as? String {
                            let wish = Wish(id: doc.documentID, text: text)
                            self.wishes.append(wish)
                        }
                    }
                    DispatchQueue.main.async {
                        self.wishTableView.reloadData()
                    }
                }
        }
    }
    
    func updateWishText(_ updatedText: String, at indexPath: IndexPath) {
        
        var wishToEdit = wishes[indexPath.row]
        wishToEdit.text = updatedText
        
        self.db.collection("wishes").document(wishToEdit.id).updateData([
            "text": updatedText
        ]) { error in
            if let error = error {
                print("Update error: \(error.localizedDescription)")
                Haptics.error()
                self.showAlert(title: "Updating is failed", message: error.localizedDescription)
                
            } else {
                self.wishes[indexPath.row].text = updatedText
                DispatchQueue.main.async {
                    self.wishTableView.reloadData()
                }
                print("Wish updated successfully")
                
                Haptics.success()
                self.showToast("The wish updated successfully")
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addButton(addButton)
        return true
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = wishes[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let wishToDelete = wishes[indexPath.row]
            
            db.collection("wishes").document(wishToDelete.id).delete { err in
                if let error = err {
                    print("Deleting error \(error.localizedDescription)")
                    self.showAlert(title: "Deleting is failed", message: error.localizedDescription)
                    
                } else {
                    print("Wish deleted from Firestore successfully")
                    
                    Haptics.success()
                    self.showToast("The wish deleted successfully")
                }
            }
            wishes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let alert = UIAlertController(title: "Edit Wish", message: "Update your wish below", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = self.wishes[indexPath.row].text
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let updatedText = alert.textFields?.first?.text, !updatedText.isEmpty else { return }
            self.updateWishText(updatedText, at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

