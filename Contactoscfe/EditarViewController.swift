//
//  EditarViewController.swift
//  Contactoscfe
//
//  Created by marco rodriguez on 16/08/22.
//

import UIKit
import CoreData

class EditarViewController: UIViewController {
    
    var recibirContacto: Contacto?
    
    // MARK: - Contexto
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var emailEditar: UITextField!
    @IBOutlet weak var direccionEditar: UITextField!
    @IBOutlet weak var telefonoEditar: UITextField!
    @IBOutlet weak var nombreEditar: UITextField!
    @IBOutlet weak var imagenEditar: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mostrarContactoEditar()
        
        gesturaImagen()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func gesturaImagen(){
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired = 1
        imagenEditar.addGestureRecognizer(gestura)
        imagenEditar.isUserInteractionEnabled = true
    }
    
    @objc func clickImagen(){
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func mostrarContactoEditar(){
        nombreEditar.text = recibirContacto?.nombre
        telefonoEditar.text = "\(recibirContacto?.telefono ?? 0)"
        direccionEditar.text = recibirContacto?.direccion
        emailEditar.text = recibirContacto?.email
        imagenEditar.image = UIImage(data: (recibirContacto?.imagen!)!)
        
    }
    
    @IBAction func guardarButton(_ sender: Any) {
        recibirContacto?.nombre = nombreEditar.text
        recibirContacto?.telefono = Int64(telefonoEditar.text ?? "0")!
        recibirContacto?.direccion = direccionEditar.text
        recibirContacto?.email = emailEditar.text
        recibirContacto?.imagen = imagenEditar.image?.pngData()
        
        try? contexto.save()
        
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func cancelarBtn(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

}

extension EditarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imagenEditar.image = imagenSeleccionada
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
