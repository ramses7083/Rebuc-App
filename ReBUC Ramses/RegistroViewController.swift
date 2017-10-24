//
//  RegistroViewController.swift
//  ReBUC Ramses
//
//  Created by Ramses Miramontes Meza on 18/10/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit
import SQLite

class RegistroViewController: UIViewController {
    // Propiedades de la base de datos
    var database: Connection!
    let usuariosTabla = Table("Usuarios")
    let idUsuarioExp = Expression<Int>("id_usuario")
    let emailExp = Expression<String>("email")
    let contrasenaExp = Expression<String>("contrasena")
    let nombreUsuarioExp = Expression<String>("nombre_usuario")
    let apellido_usuarioExp = Expression<String>("apellido_usuario")
    let dependenciaExp = Expression<String>("dependencia")
    let idTipoUsuarioExp = Expression<Int>("id_tipo_usuario")
    
    // Objetos que utilizaremos en este controlador
    @IBOutlet var nombreTextField: UITextField!
    @IBOutlet var apellidoTextField: UITextField!
    @IBOutlet var dependenciaTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var contrasenaTextField: UITextField!
    
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
        
        // Crear la tabla de Usuarios
        let crearTabla = self.usuariosTabla.create { (tabla) in
            tabla.column(self.idUsuarioExp, primaryKey: true)
            tabla.column(self.emailExp, unique: true)
            tabla.column(self.contrasenaExp)
            tabla.column(self.nombreUsuarioExp)
            tabla.column(self.apellido_usuarioExp)
            tabla.column(self.dependenciaExp)
            tabla.column(self.idTipoUsuarioExp)
        }
        
        do {
            try self.database.run(crearTabla)
            print("Tabla creada")
        } catch {
            print(error)
        }
    }

    @IBAction func registrarUsuario(_ sender: UIButton) {
        let registrarUsuario = self.usuariosTabla.insert(self.emailExp <- emailTextField.text!, self.contrasenaExp <- contrasenaTextField.text!, self.nombreUsuarioExp <- nombreTextField.text!,self.apellido_usuarioExp <- apellidoTextField.text!, self.dependenciaExp <- dependenciaTextField.text!, idTipoUsuarioExp <- 1)
        
        do {
            try self.database.run(registrarUsuario)
            print("Usuario \(self.emailTextField.text!) guardado")
            let alert = UIAlertController(title: "Éxito", message: "El usuario se ha guardado exitosamente", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (_) in
            
                // Reinciamos los TextFields
                self.nombreTextField.text = ""
                self.apellidoTextField.text = ""
                self.dependenciaTextField.text = ""
                self.emailTextField.text = ""
                self.contrasenaTextField.text = ""
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
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
