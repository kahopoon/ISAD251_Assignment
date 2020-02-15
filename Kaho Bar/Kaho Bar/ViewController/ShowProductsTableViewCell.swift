//
//  ShowProductsTableViewCell.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

class ShowProductsTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productAvailability: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithProduct(_ product: Product) {
        DispatchQueue.main.async {
            self.productImage.sd_setImage(with: URL(string: product.imagePath), placeholderImage: UIImage(named: ""))
            self.productImage.layer.cornerRadius = 10
            self.productImage.layer.masksToBounds = true
            self.productName.text = product.name
            self.productDescription.text = product.description
            self.productPrice.text = "‎£\(product.price)"
            switch product.status {
            case .inactive:
                self.productAvailability.text = "Unavailable"
                self.productAvailability.textColor = UIColor.red
            default:
                self.productAvailability.text = "Available"
                self.productAvailability.textColor = UIColor.green
            }
        }
        
    }

}
