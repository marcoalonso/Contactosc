//
//  TableViewCell.swift
//  Contactoscfe
//
//  Created by marco rodriguez on 17/08/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var direccionContacto: UILabel!
    @IBOutlet weak var nombreContacto: UILabel!
    @IBOutlet weak var telefonoContacto: UILabel!
    @IBOutlet weak var imagenContacto: UIImageView!
    @IBOutlet weak var emailContacto: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imagenContacto.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
