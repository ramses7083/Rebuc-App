//
//  UniverComentarTicketsViewController.swift
//  ReBUC Ramses
//
//  Created by Ramses Miramontes Meza on 30/10/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit
import SQLite

class UniverComentarTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Objeto que se utilizará
    @IBOutlet var respuestasTableView: UITableView!
    @IBOutlet var descripcionLabel: UILabel!
    @IBOutlet var preguntaTextField: UITextField!
    
    // Tabla de respuestas de tickets
    var database: Connection!
    let historialTicketsTabla = Table("Historial_tickets")
    let idHistorialTicketExp = Expression<Int>("id_historial_ticket")
    let idTicketExp = Expression<Int>("id_ticket")
    let idRespuestaUsuarioExp = Expression<Int>("id_respuesta_usuario")
    let fechaRespuestaExp = Expression<String>("fecha_respuesta")
    let respuestaExp = Expression<String>("respuesta")
    
    // Variables a utilizar
    var idUsuario : Int!
    var idTicket :Int!
    var descripcion: String!
    var fechaActual : String!
    var respuestas = [String]()
    var fechas = [String]()
    
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
        
        // Cargar la descripcion en el label
        descripcionLabel.text = descripcion
        
        // Convocar al método para obtener los comentarios de los tickets
        obtenerComentarios()
    }
    
    // Método para obtener los comentarios de cada ticket y guardarlos en arreglos
    func obtenerComentarios() {
        respuestas.removeAll()
        fechas.removeAll()
        do {
            let historialTickets = self.historialTicketsTabla.filter(self.idTicketExp == idTicket!)
            for respuestaTicket in try database.prepare(historialTickets) {
                self.respuestas.append(respuestaTicket[self.respuestaExp])
                self.fechas.append(respuestaTicket[self.fechaRespuestaExp])
            }
        } catch {
            print(error)
        }
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return respuestas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = respuestas[indexPath.row]
        cell.detailTextLabel?.text = fechas[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Seleccionaste la respuesta: \(respuestas[indexPath.row])")
    }

    @IBAction func enviarPregunta(_ sender: UIButton) {
        // Crear la tabla de historial tickets
        let crearTabla = self.historialTicketsTabla.create { (tabla) in
            tabla.column(self.idHistorialTicketExp, primaryKey: true)
            tabla.column(self.idTicketExp)
            tabla.column(self.idRespuestaUsuarioExp)
            tabla.column(self.fechaRespuestaExp)
            tabla.column(self.respuestaExp)
        }
        
        do {
            try self.database.run(crearTabla)
            print("Tabla de historial de tickets creada")
        } catch {
            print(error)
        }
        
        // Obtener fecha actual
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        fechaActual = formatter.string(from: date)
        
        // Guardar el ticket
        let registrarRespuesta = self.historialTicketsTabla.insert(self.idTicketExp <- self.idTicket!, self.idRespuestaUsuarioExp <- self.idUsuario!, self.fechaRespuestaExp <- self.fechaActual!, self.respuestaExp <- self.preguntaTextField.text!)
        
        do {
            try self.database.run(registrarRespuesta)
            print("Respuesta registrada con fecha \(self.fechaActual!) y pregunta: \(self.preguntaTextField.text!) del usuario \(self.idUsuario!)")
            // Ejecutar un alert
            let alert = UIAlertController(title: "Éxito!", message: "Pregunta guardada correctamente", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (_) in
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            // Reiniciar text field
            self.preguntaTextField.text = ""
            
            // Reiniciar tabla
            obtenerComentarios()
            self.respuestasTableView.reloadData()
            
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
