//
//  SOAViewController.swift
//  CRUD-MVC
//
//  Created by Victor Sanchez on 2/11/22.
//

import UIKit

class SOAViewController: UIViewController {
    
    let databaseService = ServiceRegistry.databaseService
    var movies = [Movie]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        title = "SOA"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        getMovies()
    }
    
    //MARK: Agregar Películas
    @IBAction func addMovieBtn(_ sender: UIButton) {
        if self.titleTextField.text == "" || self.descriptionTextField.text == "" || self.yearTextField.text == "" {
            self.showAlert(
                title: nil,
                message: "Los campos no pueden estar vacíos, revise la información e intente de nuevo")
        } else {
//            databaseService.collection("movielist").addDocument(
//                data:
//                    [
//                        "title": self.titleTextField.text!,
//                        "description": self.descriptionTextField.text!,
//                        "year": self.yearTextField.text!
//                    ]
//            )
            self.cleanFields()
            self.showAlert(title: "Película gregada", message: "La película ha sido agregada satisfactoriamente")
        }
    }
    
    //MARK: Obtener Películas
    func getMovies(){
        databaseService.getMovies { movies in
            self.movies = movies
            self.tableView.reloadData()
        } failure: { error in
            self.showAlert(title: nil, message: "Ocurrió un error al cargar la información")
        }
        
    }
    
    //MARK: Mostrar alerta
    func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title ?? "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    //MARK: Limpiar campos de texto
    func cleanFields() {
        self.titleTextField.text = ""
        self.descriptionTextField.text = ""
        self.yearTextField.text = ""
        self.titleTextField.endEditing(true)
        self.descriptionTextField.endEditing(true)
        self.yearTextField.endEditing(true)
    }
}

extension SOAViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Obtener numero de filas de la tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    //MARK: Asignar textos a las filas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellController
        cell.titleLabel.text = "Titulo: \(self.movies[indexPath.row].title)"
        cell.yearLabel.text = "Año: \(self.movies[indexPath.row].year)"
        cell.descriptionLabel.text = "Descripción: \(self.movies[indexPath.row].description)"
        return cell
    }
    
    //MARK: Funciones de editar y borrar
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let movie = self.movies[indexPath.row]
        
        //MARK: Editar
        let editButton = UIContextualAction(style: .normal, title: "Editar") { (_, _, _) in
            
            let alert = UIAlertController(title: "Editar Película", message: "Editar la información de la película", preferredStyle: .alert)
            
            //MARK: Campos de texto
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
            
            //MARK: Botones de la alerta
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            
            alert.addAction(
                UIAlertAction(
                    title: "Guardar",
                    style: .default,
                    handler: { _ in
                        guard let fields = alert.textFields, fields.count == 3 else { return }
                        
                        let titleField = fields[0]
                        let yearField = fields[1]
                        let descriptionField = fields[2]
                        
                        guard let title = titleField.text,
                              !title.isEmpty,
                              let year = yearField.text,
                              !year.isEmpty,
                              let description = descriptionField.text,
                              !description.isEmpty else {
                            self.showAlert(
                                title: nil,
                                message: "Los campos no pueden estar vacíos, revise la información e intente de nuevo")
                            return }
                        
                        guard let id = movie.id else { return }
                        
//                        self.db.collection("movielist")
//                            .document(id)
//                            .setData([
//                                "title": title,
//                                "year": year,
//                                "description": description
//                            ])
                    }
                )
            )
            
            self.present(alert, animated: true)
        }
        
        //MARK: Borrar
        let deleteButton = UIContextualAction(style: .destructive, title: "Borrar") { (_, _, _) in
//            self.db.collection("movielist").document(movie.id!).delete()
        }
        
        let actions = UISwipeActionsConfiguration(actions: [deleteButton, editButton])
        
        return actions
    }
    
    //MARK: Permitir edición de la fila
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}


