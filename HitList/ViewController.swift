

import UIKit
import CoreData

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var people: [Person] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    config()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchData()
  }
  
  private func config() {
    title = "People"
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
  
  private func fetchData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
    
    do {
      people = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  @IBAction func addName(_ sender: UIBarButtonItem) {
    showAlert(title: "New Person", message: "Enter new info") {[weak self] name, phone in
      self?.save(name: name, phone: phone)
    }
  }
  
  func update(name: String,phone: String,  index: Int) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    let person = self.people[index]
    person.name = name
    person.phone = phone

    do {
      try managedContext.save()
      self.tableView.reloadData()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
  
  func save(name: String, phone: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext
    
    let person = Person.init(context: managedContext)
    person.name = name
    person.phone = phone
    managedContext.insert(person)
    
    do {
      people.append(person)
      try managedContext.save()
      
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let person = people[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.text = "Name: \(person.name ?? "")" + "\n" + "Phone: \(person.phone ?? "")"
    return cell
  }
}


extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showAlert(title: "Update", message: "Enter new info") {[weak self] name, phone in
      self?.update(name: name, phone: phone, index: indexPath.row)
    }
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      let managedContext = appDelegate.persistentContainer.viewContext
      managedContext.delete(self.people[indexPath.row])
      self.people.remove(at: indexPath.row)
      try? managedContext.save()
      self.tableView.reloadData()
    }
  }
  func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    return "Delete"
  }
}

extension ViewController {
  func showAlert(title: String, message: String, saveCompletionHandler:((_ name: String, _ phone: String) -> Void)?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let saveAction = UIAlertAction(title: "Save", style: .default) { action in

      guard let textField = alert.textFields?.first,
        let nameToSave = textField.text else {
          return
      }
      
      guard let textField = alert.textFields?[1],
        let phoneToSave = textField.text else {
          return
      }

      saveCompletionHandler?(nameToSave, phoneToSave)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alert.addTextField { nameTextField in
      nameTextField.placeholder = "name"
    }
    
    alert.addTextField { phoneTextFiled in
      phoneTextFiled.placeholder = "phone"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert, animated: true)
  }
}
