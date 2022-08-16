//
//  ViewController.swift
//  Contactoscfe
//
//  Created by marco rodriguez on 16/08/22.
//

import UIKit
import CoreData
import MessageUI

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tablaContactos: UITableView!
    
    // MARK: - Variables
    var contactos: [Contacto] = []
    var contactoEditar: Contacto?
    
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tablaContactos.delegate = self
        tablaContactos.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        leerContactos()
    }
    
    @IBAction func nuevoContactoButton(_ sender: UIBarButtonItem) {
    
        //Agregar alerta
        let alerta = UIAlertController(title: "Agregar contacto", message: "Nuevo", preferredStyle: .alert)
        
        //Agregar TextField a la alerta
        alerta.addTextField { nombreTF in
            nombreTF.placeholder = "Nombre"
            nombreTF.textColor = .blue
            nombreTF.font = UIFont(name: "Avenir", size: 22)
        }
        
        alerta.addTextField { telefonoTF in
            telefonoTF.placeholder = "Telefono"
            telefonoTF.textColor = .blue
            telefonoTF.font = UIFont(name: "Avenir", size: 20)
            telefonoTF.keyboardType = .numberPad
        }
        
        alerta.addTextField { direccionTF in
            direccionTF.placeholder = "Direccion"
            direccionTF.textColor = .blue
            direccionTF.font = UIFont(name: "Avenir", size: 18)
        }
        
        alerta.addTextField { emailTF in
            emailTF.placeholder = "Email"
            emailTF.textColor = .blue
            emailTF.font = UIFont(name: "Avenir", size: 18)
            emailTF.keyboardType = .emailAddress
        }
        
        
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
            //1.- Extraer los atributos p crear el nuevo contacto
            guard let nombreAlerta = alerta.textFields?[0].text else { return }
            guard let telefonoAlerta = Int64(alerta.textFields?[1].text ?? "0") else { return }
            guard let direccionAlerta = alerta.textFields?[2].text else { return }
            guard let emailAlerta = alerta.textFields?[3].text else { return }
            let imageTemporal = UIImageView(image: UIImage(named: "emoji"))
            
            //2.- Crear el nuevo contacto
            let contexto = self.conexion()
            let nuevoContacto = Contacto(context: contexto)
            nuevoContacto.nombre = nombreAlerta
            nuevoContacto.telefono = telefonoAlerta
            nuevoContacto.direccion = direccionAlerta
            nuevoContacto.email = emailAlerta
            nuevoContacto.imagen = imageTemporal.image?.pngData()
            
            //3.- guardar contexto
            self.contactos.append(nuevoContacto)
            self.guardarContexto()
            
            //4.- Actualizar UI (agregar al array y actualizar tabla)
            self.tablaContactos.reloadData()
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .destructive, handler: nil)
        alerta.addAction(accionAceptar)
        alerta.addAction(accionCancelar)
        present(alerta, animated: true, completion: nil)
    }
    
    func guardarContexto(){
        //try? self.conexion().save()
        let contexto = conexion()
        do {
            try contexto.save()
        } catch  {
            print("Error al guardar en la bd", error.localizedDescription)
        }
    }
    
    func leerContactos(){
        let contexto = conexion()
        let solicitud : NSFetchRequest<Contacto> = Contacto.fetchRequest()
        do {
            contactos =  try contexto.fetch(solicitud)
        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        tablaContactos.reloadData()
    }
    
}

// MARK: - Enviar Email Protocol
extension ViewController: MFMailComposeViewControllerDelegate {
    func showMail(correo: String, nombre: String){
        if !MFMailComposeViewController.canSendMail() {
            print("No esta configurada ninguna cuenta de correo")
        }
        
        //Si se pueda enviar
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        //Configurar el cueroo del correo
        composeVC.setToRecipients(["\(correo)"])
        composeVC.setSubject("Hola \(nombre)")
        composeVC.setMessageBody("", isHTML: false)
        self.present(composeVC, animated: true)
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelado")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        case .failed:
            print("failed")
        }
        
        controller.dismiss(animated: true)
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaContactos.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        celda.textLabel?.text = contactos[indexPath.row].nombre
        celda.detailTextLabel?.text = "\(contactos[indexPath.row].telefono)"
        celda.imageView?.image = UIImage(data: contactos[indexPath.row].imagen!)
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactoEditar = contactos[indexPath.row]
        
        performSegue(withIdentifier: "editar", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let EditarContacto = segue.destination as! EditarViewController
        EditarContacto.recibirContacto = contactoEditar
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar  = UIContextualAction(style: .normal, title: "") { _, _, _ in
            
            let contexto = self.conexion()
            contexto.delete(self.contactos[indexPath.row])
            self.contactos.remove(at: indexPath.row)
            self.guardarContexto()
            self.tablaContactos.reloadData()
        }
        
        accionEliminar.image = UIImage(systemName: "trash")
        accionEliminar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEmail = UIContextualAction(style: .normal, title: "") { _, _, _ in
            
            guard let email = self.contactos[indexPath.row].email else { return }
            guard let nombre = self.contactos[indexPath.row].nombre else { return }
            self.showMail(correo: email, nombre: nombre)
        }
        
        let accionLlamada = UIContextualAction(style: .normal, title: "") { _, _, _ in
            
            //Extraer el num telefono
            //guard let numTelefono = "\(self.contactos[indexPath.row].telefono)" else { return }
            
            if let llamadaURL = URL(string: "TEL://8181814990") {
                let aplicacionLllamda : UIApplication = UIApplication.shared
                if (aplicacionLllamda.canOpenURL(llamadaURL)) {
                    aplicacionLllamda.open(llamadaURL, options: [:], completionHandler: nil)
                }
            }
            
        }
        
        accionLlamada.image = UIImage(systemName: "phone.arrow.right")
        accionLlamada.backgroundColor = .green
        
        accionEmail.image = UIImage(systemName: "mail")
        accionEmail.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [accionEmail, accionLlamada])
    }
}
