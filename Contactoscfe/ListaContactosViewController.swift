//
//  ViewController.swift
//  Contactoscfe
//
//  Created by marco rodriguez on 16/08/22.
//

import UIKit
import CoreData
import MessageUI

class ListaContactosViewController: UIViewController {
    
    @IBOutlet weak var buscarContactoTF: UITextField!
    
    @IBOutlet weak var tablaContactos: UITableView!
    
    // MARK: - Variables
    var contactos: [Contacto] = []
    var contactoEditar: Contacto?
    private var direccionVisualizar: String = ""
    
    //Predicados en core data para filtrar elementos
    var commitPredicate: NSPredicate?
    
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buscarContactoTF.delegate = self
        
        //Registrar la celda personalizada en la tabla
        tablaContactos.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "celda")
        
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
        self.contactos.removeAll()
        let contexto = conexion()
        let solicitud : NSFetchRequest<Contacto> = Contacto.fetchRequest()
        do {
            contactos =  try contexto.fetch(solicitud)
            print("Debug: Read DB \(contactos)")
        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        tablaContactos.reloadData()
    }
    
    func buscarContacto(filtro: String){
        self.commitPredicate = NSPredicate(format: "nombre CONTAINS[c] '\(filtro)'")
        
        let contexto = conexion()
        let solicitud : NSFetchRequest<Contacto> = Contacto.fetchRequest()
        solicitud.predicate = commitPredicate
        
        do {
            contactos =  try contexto.fetch(solicitud)
        } catch  {
            print("Error al leer de core data,",error.localizedDescription)
        }
        tablaContactos.reloadData()
    }
    
}
//MARK: UITextFieldDelegate
extension ListaContactosViewController: UITextFieldDelegate {
    //1.- Habilitar el boton del teclado virtual
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Hacer algo ")
        //ocultar teclado
        buscarContactoTF.endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            leerContactos()
        }
        buscarContacto(filtro: textField.text ?? "M")
    }
    
    //2.- Identificar cuando el usuario termina de editar y que pueda borrar el contenido del textField
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Hacer algo
        buscarContacto(filtro: textField.text ?? "M")
        //ocultar teclado
        buscarContactoTF.endEditing(true)
    }
    
    //3.- Evitar que el usuario no escriba nada
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if buscarContactoTF.text != "" {
            return true
        } else {
            //el usuario no escribio nada
            buscarContactoTF.placeholder = "Debes escribir algo.."
            return false
        }
    }
}

// MARK: - Enviar Email Protocol
extension ListaContactosViewController: MFMailComposeViewControllerDelegate {
    func showMail(correo: String, nombre: String){
        if !MFMailComposeViewController.canSendMail() {
            print("No esta configurada ninguna cuenta de correo")
        } else {
            //Si se pueda enviar
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            //Configurar el cueroo del correo
            composeVC.setToRecipients(["\(correo)"])
            composeVC.setSubject("Hola \(nombre)")
            composeVC.setMessageBody("", isHTML: false)
            self.present(composeVC, animated: true)
        }
        
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            controller.dismiss(animated: true)
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelado")
            DispatchQueue.main.async {
                
                self.mostrarMSJUsuario(msj: "Cancelado")
            }
            
        case .saved:
            print("saved")
            DispatchQueue.main.async {
                self.mostrarMSJUsuario(msj: "Se Guardado en borradores")
            }
        case .sent:
            print("sent")
            DispatchQueue.main.async {
                self.mostrarMSJUsuario(msj: "Ah sido enviado")
            }
        case .failed:
            mostrarMSJUsuario(msj: "Fallo")
        }
        
        controller.dismiss(animated: true)
    }
    
    func mostrarMSJUsuario(msj: String){
        let alerta = UIAlertController(title: "TU CORREO:", message: msj, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(accionAceptar)
        present(alerta, animated: true, completion: nil)
    }
    
    
}

extension ListaContactosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tablaContactos.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! TableViewCell
        
        celda.nombreContacto.text = contactos[indexPath.row].nombre
        celda.telefonoContacto.text = "📞 \(contactos[indexPath.row].telefono)"
        celda.emailContacto.text = "📨 \(contactos[indexPath.row].email ?? "")"
        celda.direccionContacto.text = "🏡 \(contactos[indexPath.row].direccion ?? "")"
        celda.imagenContacto.image = UIImage(data: contactos[indexPath.row].imagen!)
        return celda
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactoEditar = contactos[indexPath.row]
        direccionVisualizar = self.contactos[indexPath.row].direccion ?? ""
        performSegue(withIdentifier: "editar", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editar" {
            let EditarContacto = segue.destination as! EditarViewController
            EditarContacto.recibirContacto = contactoEditar
        }
        
        if segue.identifier == "mapa" {
            let direccionMapa = segue.destination as! MapaViewController
            direccionMapa.direccionUser = direccionVisualizar
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar  = UIContextualAction(style: .normal, title: "") { _, _, _ in
            
            let contexto = self.conexion()
            contexto.delete(self.contactos[indexPath.row])
            self.contactos.remove(at: indexPath.row)
            self.guardarContexto()
            self.tablaContactos.reloadData()
        }
        
        let accionMapa = UIContextualAction(style: .normal, title: "") { _, _, _ in
            self.direccionVisualizar = self.contactos[indexPath.row].direccion ?? "Morelia, Michoacan"
            self.performSegue(withIdentifier: "mapa", sender: self)
        }
        
        let accionEditar = UIContextualAction(style: .normal, title: "") { _, _, _ in
            self.contactoEditar = self.contactos[indexPath.row]
            self.performSegue(withIdentifier: "editar", sender: self)
        }
        
        accionEditar.image = UIImage(systemName: "pencil")
        accionEditar.backgroundColor = .orange
        
        accionMapa.image = UIImage(systemName: "mappin.and.ellipse")
        accionMapa.backgroundColor = .blue
        
        accionEliminar.image = UIImage(systemName: "trash")
        accionEliminar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionEliminar, accionMapa, accionEditar])
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
            let numero: Int64 = self.contactos[indexPath.row].telefono
                
            let numString = String(numero)
        
            
            if let llamadaURL = URL(string: "TEL://\(numString)") {
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
