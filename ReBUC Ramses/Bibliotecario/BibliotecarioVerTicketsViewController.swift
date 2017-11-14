//
//  BibliotecarioVerTicketsViewController.swift
//  ReBUC Ramses
//
//  Created by Ramses Miramontes Meza on 02/11/17.
//  Copyright © 2017 Ramses Miramontes Meza. All rights reserved.
//

import UIKit
import SQLite

class BibliotecarioVerTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // Objeto que se utilizará
    @IBOutlet var ticketsTableView: UITableView!
    
    // Tabla de sesion activa
    var database: Connection!
    let sesionTabla = Table("Sesion")
    let idUsuarioSesExp = Expression<Int>("id_usuario")
    
    // Tabla de Tickets
    let ticketsTabla = Table("Tickets")
    let idTicketExp = Expression<Int>("id_ticket")
    let idUsuarioExp = Expression<Int>("id_usuario")
    let idUsuarioBibliotecarioExp = Expression<Int>("id_usuario_bibliotecario")
    let fechaTicketExp = Expression<String>("fecha_ticket")
    let consultaExp = Expression<String>("consulta")
    let estatusExp = Expression<String>("estatus")
    let calificacionExp = Expression<Int>("calificacion")
    
    // Variables a utilizar
    var idUsuario : Int!
    var idTicket : Int!
    var descripcion : String!
    var estatusTicket : String!
    var idTickets = [Int]()
    var consultas = [String]()
    var estatus = [String]()
    
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
        
        // Obtener los datos de cada ticket y guardarlos en arreglos
        do {
            let tickets = self.ticketsTabla.filter(self.idUsuarioBibliotecarioExp == idUsuario! || self.idUsuarioBibliotecarioExp == 0)
            for ticket in try database.prepare(tickets) {
                self.idTickets.append(ticket[self.idTicketExp])
                self.consultas.append(ticket[self.consultaExp])
                self.estatus.append(ticket[self.estatusExp])
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
        return idTickets.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = consultas[indexPath.row]
        cell.detailTextLabel?.text = estatus[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Seleccionaste el ticket número \(idTickets[indexPath.row])")
        self.idTicket = idTickets[indexPath.row]
        self.descripcion = consultas[indexPath.row]
        self.estatusTicket = estatus[indexPath.row]
        if estatus[indexPath.row] == "Nuevo" {
            let alert = UIAlertController(title: "Ticket sin asignación", message: "Desear tomar este ticket?", preferredStyle: .alert)
            let tomar = UIAlertAction(title: "TOMAR", style: .default) { (_) in
                let ticket = self.ticketsTabla.filter(self.idTicketExp == self.idTicket!)
                let ticketTomado = ticket.update(self.idUsuarioBibliotecarioExp <- self.idUsuario!, self.estatusExp <- "En proceso")
                do {
                    try self.database.run(ticketTomado)
                    self.performSegue(withIdentifier: "bibliotecarioTicketSegue", sender: self)
                } catch {
                    print(error)
                }
            }
            let cancelar = UIAlertAction(title: "Cancelar", style: .default) { (_) in
            }
            alert.addAction(tomar)
            alert.addAction(cancelar)
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "bibliotecarioTicketSegue", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reiniciar datos
        idTickets.removeAll()
        consultas.removeAll()
        estatus.removeAll()
        
        // Obtener los datos de cada ticket y guardarlos en arreglos
        do {
            let tickets = self.ticketsTabla.filter(self.idUsuarioBibliotecarioExp == idUsuario! || self.idUsuarioBibliotecarioExp == 0)
            for ticket in try database.prepare(tickets) {
                self.idTickets.append(ticket[self.idTicketExp])
                self.consultas.append(ticket[self.consultaExp])
                self.estatus.append(ticket[self.estatusExp])
            }
        } catch {
            print(error)
        }
        
        // Recargar tabla
        ticketsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bibliotecarioTicketSegue" {
            let vc : BibliotecarioResponderTicketViewController = segue.destination as! BibliotecarioResponderTicketViewController
            vc.idUsuario = self.idUsuario
            vc.idTicket = self.idTicket
            vc.descripcion = self.descripcion
            vc.estatus = self.estatusTicket
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
