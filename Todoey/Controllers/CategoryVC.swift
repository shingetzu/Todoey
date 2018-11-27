//
//  CategoryVC.swift
//  Todoey
//
//  Created by Jonathan Go on 2018/11/27.
//  Copyright © 2018 Appdelight. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryVC: SwipeTableViewController {

  let realm = try! Realm()
  var categories: Results<Category>?
  
    override func viewDidLoad() {
        super.viewDidLoad()

      loadCategories()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return categories?.count ?? 1
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = super.tableView(tableView, cellForRowAt: indexPath)
      if let category = categories?[indexPath.row] {
        cell.textLabel?.text = category.name
        guard let categoryColour = UIColor(hexString: category.colour) else { fatalError() }
        cell.backgroundColor = categoryColour
        cell.textLabel?.textColor = ContrastColorOf(backgroundColor: categoryColour, returnFlat: true)
      }
      return cell
    }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "toItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! ToDoVC
    
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.selectedCategory = categories?[indexPath.row]
    }
  }
  
  
  @IBAction func addCatBtnPressed(_ sender: Any) {
    var textfield = UITextField()
    
    let alert = UIAlertController(title: "Add New ToDoey Category", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "Add", style: .default) { (action) in
      //what will happen when Add Category is clicked
      let newCat = Category()
      newCat.name = textfield.text!
      newCat.colour = UIColor.randomFlat().hexValue()
      
      if let _ = self.categories?.first(where: { $0.name.lowercased() == newCat.name.lowercased()}){
        print("Found duplicate \(String(describing: newCat.name))")
        return
      }
      
      self.saveToRealm(category: newCat)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alert.addTextField { (alertTextField) in
      alertTextField.placeholder = "Create new category"
      textfield = alertTextField
    }
    
    alert.addAction(action)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Data Manipulation Methods
  func saveToRealm(category: Category) {
    do {
      try realm.write {
        realm.add(category)
      }
    } catch {
      print("Error saving context, \(error.localizedDescription)")
    }
    self.tableView.reloadData()
  }
  
  func loadCategories() {
    categories = realm.objects(Category.self)
    
    tableView.reloadData()
  }
  
  //: MARK - Delete Data from Swipe
  override func updateModel(at indexPath: IndexPath) {
    super.updateModel(at: indexPath)
    
    guard let categoryForDeletion = self.categories?[indexPath.row] else { return }
    do {
      try self.realm.write {
        self.realm.delete(categoryForDeletion)
      }
    } catch {
      print("Error deleting category, \(error.localizedDescription)")
    }
  }
}
