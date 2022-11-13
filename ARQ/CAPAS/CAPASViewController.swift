//
//  CAPASViewController.swift
//  ARQ
//

import UIKit
import FirebaseFirestore

protocol ListMoviesDisplayLogic: AnyObject
{
    func displayFetchedMovies(viewModel: ListMovies.FetchMovies.ViewModel)
}

class CAPASViewController: UIViewController, ListMoviesDisplayLogic {
    
    var interactor: ListMoviesBusinessLogic?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        title = "CAPAS"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetchMovies()
    }
    
    private func setup()
    {
        let viewController = self
        let interactor = ListMoviesInteractor()
        let presenter = ListMoviesPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    //MARK: Agregar Películas
    @IBAction func addMovieBtn(_ sender: UIButton) {
        if self.titleTextField.text == "" || self.descriptionTextField.text == "" || self.yearTextField.text == "" {
            self.showAlert(
                title: nil,
                message: "Los campos no pueden estar vacíos, revise la información e intente de nuevo")
        } else {
            let movie = ListMovies.FetchMovies.Add(title: self.titleTextField.text!, description: self.descriptionTextField.text!, year: self.yearTextField.text!)
            interactor?.addMovies(movie: movie)
            
            self.cleanFields()
            self.showAlert(title: "Película agregada", message: "La película ha sido agregada satisfactoriamente")
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
    
    
    var displayedMovies: [ListMovies.FetchMovies.ViewModel.DisplayedMovies] = []
    
    func fetchMovies() {
        let request = ListMovies.FetchMovies.Request()
        interactor?.fetchMovies(request: request)
    }
    
    func displayFetchedMovies(viewModel: ListMovies.FetchMovies.ViewModel) {
        displayedMovies = viewModel.displayedMovies
        tableView.reloadData()
    }
}

extension CAPASViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Obtener numero de filas de la tabla
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedMovies.count
    }
    
    //MARK: Asignar textos a las filas
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = displayedMovies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCellController
        cell.titleLabel.text = "Titulo: \(movie.title)"
        cell.yearLabel.text = "Año: \(movie.year)"
        cell.descriptionLabel.text = "Descripción: \(movie.description)"
        return cell
    }
    
    //MARK: Funciones de editar y borrar
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let movie = self.displayedMovies[indexPath.row]
        
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
                        var movieToEdit = ListMovies.FetchMovies.ViewModel.DisplayedMovies(id: id, title: title, description: description, year: year)
                        self.interactor?.editMovies(movie: movieToEdit)
  
                    }
                )
            )
            
            self.present(alert, animated: true)
        }
        
        //MARK: Borrar
        let deleteButton = UIContextualAction(style: .destructive, title: "Borrar") { (_, _, _) in
            self.interactor?.deleteMovies(movie: movie)
        }
        
        let actions = UISwipeActionsConfiguration(actions: [deleteButton, editButton])
        
        return actions
    }
    
    //MARK: Permitir edición de la fila
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

