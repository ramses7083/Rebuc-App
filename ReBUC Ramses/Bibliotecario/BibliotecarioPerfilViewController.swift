//
//  BibliotecarioPerfilViewController.swift
//  ReBUC Ramses
//
//  Created by Ramses Miramontes Meza on 06/11/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit
import SQLite

class BibliotecarioPerfilViewController: UIViewController {
    // Objetos que se utilizarán en este controlador
    @IBOutlet var nombreTextField: UITextField!
    @IBOutlet var apellidosTextField: UITextField!
    @IBOutlet var dependenciaTextField: UITextField!
    
    // Propiedades de la base de datos
    var database: Connection!
    let usuariosTabla = Table("Usuarios")
    let idUsuarioExp = Expression<Int>("id_usuario")
    let nombreUsuarioExp = Expression<String>("nombre_usuario")
    let apellidoUsuarioExp = Expression<String>("apellido_usuario")
    let dependenciaExp = Expression<String>("dependencia")
    
    // Tabla de sesion activa
    let sesionTabla = Table("Sesion")
    let idUsuarioSesExp = Expression<Int>("id_usuario")
    
    // Variable a utilizar
    var idUsuario : Int!

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
        
        // Obtener id del usuario que inicio sesion
        do {
            let usuarios = try self.database.prepare(self.sesionTabla)
            for usuario in usuarios {
                self.idUsuario = usuario[self.idUsuarioSesExp]
                print("El ID sesion del usuario es: \(self.idUsuario!)")
            }
        } catch {
            print(error)
        }
        
        // Obtener los datos del usuario y colocarlos en los text fields
        do {
            let datosUsuarios = self.usuariosTabla.filter(self.idUsuarioExp == idUsuario!)
            for datoUsuario in try database.prepare(datosUsuarios) {
                self.nombreTextField.text = datoUsuario[self.nombreUsuarioExp]
                self.apellidosTextField.text = datoUsuario[self.apellidoUsuarioExp]
                self.dependenciaTextField.text = datoUsuario[self.dependenciaExp]
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func actualizarDatos(_ sender: UIButton) {
        print("Usuario actualizado")
        let usuario = self.usuariosTabla.filter(self.idUsuarioExp == idUsuario)
        let usuarioActualizado = usuario.update(self.nombreUsuarioExp <- self.nombreTextField.text!, self.apellidoUsuarioExp <- self.apellidosTextField.text!, self.dependenciaExp <- self.dependenciaTextField.text!)
        do {
            try self.database.run(usuarioActualizado)
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
