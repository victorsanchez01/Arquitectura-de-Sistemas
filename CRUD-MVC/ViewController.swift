//
//  ViewController.swift
//  CRUD-MVC
//
//  Created by victor.sanchez on 27/10/22.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    var movies = [Movie]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
  
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        title = "Peliculas"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getMovies()
    }
    
    @IBAction func addMovieBtn(_ sender: UIButton) {
        if self.titleTextField.text == "" || self.descriptionTextField.text == "" || self.yearTextField.text == "" {
            print("EMPTY")
        } else {
            db.collection("movielist").addDocument(
                data:
                    [
                        "title": self.titleTextField.text!,
                        "description": self.descriptionTextField.text!,
                        "year": self.yearTextField.text!
                    ]
            )
            self.titleTextField.text = ""
            self.descriptionTextField.text = ""
            self.yearTextField.text = ""
            self.descriptionTextField.endEditing(true)
        }
    }
    
    func getMovies(){
        db.collection("movielist").addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("Error")
                return
            } else {
                self.movies = []
                for movie in querySnapshot?.documents ?? [] {
                    self.movies.append(Movie(id: movie.documentID,
                                             title: movie["title"] as? String ?? "",
                                             description: movie["description"] as? String ?? "",
                                             year: movie["year"] as? String ?? ""))
                }
                self.tableView.reloadData()
            }
            
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellController
        cell.titleLabel.text = "Titulo: \(self.movies[indexPath.row].title)"
        cell.yearLabel.text = "Año: \(self.movies[indexPath.row].year)"
        cell.descriptionLabel.text = "Descripción: \(self.movies[indexPath.row].description)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let movie = self.movies[indexPath.row]
        
        let editButton = UIContextualAction(style: .normal, title: "Editar") { (_, _, _) in
            
            let alert = UIAlertController(title: "Editar Película", message: "Editar la información de la película", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { _ in
                guard let fields = alert.textFields else { return }
                
                let titleField = fields[0]
                let yearField = fields[1]
                let descriptionField = fields[2]
                
                guard let title = titleField.text, !title.isEmpty,
                      let year = yearField.text, !year.isEmpty,
                      let description = descriptionField.text, !description.isEmpty else { return }
                guard let id = movie.id else { return }
                self.db.collection("movielist").document(id).setData(["title": title,
                                                                      "year": year,
                                                                      "description": description])
            }))
            alert.addTextField { field in
                field.text = movie.title
                field.returnKeyType = .next
            }
            alert.addTextField { field in
                field.text = movie.year
                field.returnKeyType = .next
            }
            alert.addTextField { field in
                field.text = movie.description
                field.autoresizesSubviews = true
                field.returnKeyType = .done
            }
            
            self.present(alert, animated: true)
        }
        
        let deleteButton = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            self.db.collection("movielist").document(movie.id!).delete()
        }
        
        let actions = UISwipeActionsConfiguration(actions: [deleteButton, editButton])
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
   
}

