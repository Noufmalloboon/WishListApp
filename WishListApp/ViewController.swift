//
//  ViewController.swift
//  WishListApp
//
//  Created by Nouf Alloboon on 26/10/1446 AH.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    
    @IBOutlet weak var wishTextField: UITextField!
    @IBOutlet weak var wishTableView: UITableView!
    
    let db = Firestore.firestore()
    var wishes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        wishTableView.dataSource = self
        wishTableView.delegate = self
        loadWishes()
    }
    
    @IBAction func addButton(_ sender: Any) {
        guard let wish = wishTextField.text, !wish.isEmpty else {
            return
        }
        

        
        db.collection("wishes").addDocument(data: ["text": wish, "timestamp": Timestamp()]) { err in
            DispatchQueue.main.async {
                
                if let error = err {
                    print("Saving error \(error.localizedDescription)")
                    if let index = self.wishes.firstIndex(of: wish) {
                        self.wishes.remove(at: index)
                        self.wishTableView.reloadData()
                    }
                } else {
                    print("Wish saved successfully")
                    
                    self.wishes.append(wish)
                    self.wishTextField.text = ""
                    self.wishTableView.reloadData()
                }
            }
        }
        
    }

    func loadWishes(){
        db.collection("wishes").order(by: "timestamp", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                print("Loading error \(error.localizedDescription)")
            } else {
                self.wishes = []
                if let snapshot = snapshot {
                    for doc in snapshot.documents {
                        if let text = doc["text"] as? String {
                            self.wishes.append(text)
                        }
                    }
                    self.wishTableView.reloadData()
                }
            }
        }
    }
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = wishes[indexPath.row]
        return cell
    }
    
}

