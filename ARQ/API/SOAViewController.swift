//
//  APIViewController.swift
//  ARQ
//
//  Created by Victor Sanchez on 2/11/22.
//

import UIKit

class APIViewController: UIViewController {
    
    let databaseService = ServiceRegistry.databaseService
    var movies = [MovieAPIModel]()
    var rows = 0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        title = "API"
        let reloadButton = UIBarButtonItem(title: "Reload posts", style: .done, target: self, action: #selector(loadPosts))
        self.navigationItem.rightBarButtonItem = reloadButton
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.getMovies(){ result in
            switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(_):
                    print("Error")
            }
        }
    }
    
    @objc func loadPosts(){
        self.getMovies(){ result in
            switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(_):
                    print("Error")
            }
        }
    }
    
    //MARK: Agregar Películas
    @IBAction func addMovieBtn(_ sender: UIButton) {
        if self.titleTextField.text == "" || self.descriptionTextField.text == "" || self.yearTextField.text == "" {
            self.showAlert(
                title: nil,
                message: "Los campos no pueden estar vacíos, revise la información e intente de nuevo")
        } else {
            databaseService
                .addMovie(
                    title: self.titleTextField.text!,
                    description: self.descriptionTextField.text!,
                    year: self.yearTextField.text!) { result in
                        switch result {
                            case .success(_):
                                self.cleanFields()
                                self.showAlert(title: "Película agregada", message: "La película ha sido agregada satisfactoriamente")
                            case .failure(_):
                                self.showAlert(title: nil, message: "Error al agregar la película")
                        }
                    }
        }
    }
    
    //MARK: Obtener Películas
//    func getMovies(){
//            self.databaseService.getMovies { movies in
//                self.movies = [movies]
//            } failure: { error in
//                self.showAlert(title: nil, message: "Ocurrió un error al cargar la información")
//            }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
//            print(self.movies[0].movies.count)
//            self.tableView.reloadData()
//        }
//    }
    
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

extension APIViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Obtener numero de filas de la tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows
    }
    
    //MARK: Asignar textos a las filas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellController
        cell.titleLabel.text = "Titulo: \(self.movies[0].movies[indexPath.row].fields.title)"
        cell.yearLabel.text = "Año: \(self.movies[0].movies[indexPath.row].fields.year)"
        cell.descriptionLabel.text = "Descripción: \(self.movies[0].movies[indexPath.row].fields.description)"
        return cell
    }
    
    //MARK: Funciones de editar y borrar
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let movie = self.movies[0].movies[indexPath.row]
        
        //MARK: Editar
        let editButton = UIContextualAction(style: .normal, title: "Editar") { (_, _, _) in
            
            let alert = UIAlertController(title: "Editar Película", message: "Editar la información de la película", preferredStyle: .alert)
            
            //MARK: Campos de texto
            alert.addTextField { field in
                field.text = movie.fields.title
                field.returnKeyType = .next
            }
            
            alert.addTextField { field in
                field.text = movie.fields.year
                field.returnKeyType = .next
            }
            
            alert.addTextField { field in
                field.text = movie.fields.description
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
                        
                        guard let id = movie.name else { return }
                        
                        self.databaseService.editMovie(id: id, title: title, description: description, year: year)
                    }
                )
            )
            
            self.present(alert, animated: true)
        }
        
        //MARK: Borrar
        let deleteButton = UIContextualAction(style: .destructive, title: "Borrar") { (_, _, _) in
            self.databaseService.deleteMovie(id: movie.name!)
        }
        
        let actions = UISwipeActionsConfiguration(actions: [deleteButton, editButton])
        
        return actions
    }
    //MARK: Permitir edición de la fila
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension APIViewController {
    
    func getMovies(completion: @escaping (Result<Bool, Error>) -> Void) {
        let url: URL = URL(string: "https://firestore.googleapis.com/v1/projects/arq-de-software-2022/databases/(default)/documents/movielist")!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(error!))
                    return
                }
                do {
                    let dataReceived = try JSONDecoder().decode(MovieAPIModel.self, from: data)
                    self.movies = [dataReceived]
                    self.rows = dataReceived.movies.count
                    print(self.movies[0].movies)
                    completion(.success(true))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
    }
}


