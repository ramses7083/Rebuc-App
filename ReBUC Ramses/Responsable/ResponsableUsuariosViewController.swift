//
//  ResponsableUsuariosViewController.swift
//  ReBUC Ramses
//
//  Created by Ramses Miramontes Meza on 15/11/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit
import SQLite

class ResponsableUsuariosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var usuariosTableView: UITableView!
    
    // Propiedades de la tabla de usuarios
    var database: Connection!
    let usuariosTabla = Table("Usuarios")
    let idUsuarioExp = Expression<Int>("id_usuario")
    let nombreUsuarioExp = Expression<String>("nombre_usuario")
    let apellidoUsuarioExp = Expression<String>("apellido_usuario")
    let idTipoUsuarioExp = Expression<Int>("id_tipo_usuario")
    
    // Variables a utilizar
    var idUsuarios: [Int] = []
    var nombreUsuarios: [String] = []
    var idTipoUsuarios: [Int] = []
    var tipoUsuariosData: [String] = ["Universitario", "Bibliotecario", "Responsable"]
    var idUsuario: Int!
    var idTipoUsuario: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Obtener la ruta del archivo usuarios.sqlite3
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("usuarios").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        // Convocar al método para actualizar la tabla de usuarios
        actualizarUsuarios()
    }
    
    func actualizarUsuarios() {
        // Limpiar los arreglos
        self.idUsuarios.removeAll()
        self.nombreUsuarios.removeAll()
        self.idTipoUsuarios.removeAll()
        
        // Obtener los datos de los usuarios y almacenarlos en arreglos
        do {
            for usuario in try database.prepare(self.usuariosTabla) {
                self.idUsuarios.append(usuario[self.idUsuarioExp])
                self.nombreUsuarios.append("\(usuario[self.nombreUsuarioExp]) \(usuario[self.apellidoUsuarioExp])")
                self.idTipoUsuarios.append(usuario[self.idTipoUsuarioExp])
            }
        } catch {
            print(error)
        }
        
        usuariosTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return idUsuarios.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = nombreUsuarios[indexPath.row]
        cell.detailTextLabel?.text = tipoUsuariosData[idTipoUsuarios[indexPath.row] - 1]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Seleccionaste el usuarios: \(nombreUsuarios[indexPath.row])")
        idUsuario = idUsuarios[indexPath.row]
        idTipoUsuario = idTipoUsuarios[indexPath.row]
        
        // Ejecutar un alert
        let alert = UIAlertController(title: "Cambiar privilegios", message: "¿Qué tipo de usuario es? \n\n\n\n", preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        
        //  Crear el picker view
        let pickerFrame = CGRect(x: 38, y: 52, width: 270, height: 100) // CGRectMake(left), top, width, height) - left and top are like margins
        let pickerView = UIPickerView(frame: pickerFrame)
        
        //  Colocar el datasource y delegate del pickerview
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Colocar el valor actual del picker view
        pickerView.selectRow(idTipoUsuario - 1, inComponent: 0, animated: true)
        
        //  Agregar el picker view al alert controller
        alert.view.addSubview(pickerView)
        
        let action = UIAlertAction(title: "Guardar", style: .default) { (_) in
            self.actualizarUsuarios()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    // Número de columnas
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Número de filas de los datos
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tipoUsuariosData.count
    }
    
    // Datos que contendrá cada opción
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tipoUsuariosData[row]
    }
    
    // Actualizar estatus del ticket
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let usuario = self.usuariosTabla.filter(self.idUsuarioExp == self.idUsuario!)
        let usuarioActualizado = usuario.update(self.idTipoUsuarioExp <- row + 1)
        do {
            try self.database.run(usuarioActualizado)
            print("Se actualizó el usuario \(idUsuario!) al nivel \(row + 1)")
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
