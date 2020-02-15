//
//  ShowCartTableViewCell.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit

class ShowCartTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var orderTotalPrice: UILabel!
    
    private var orderProduct:OrderProduct!
    public var cartUpdated: ((_ updated: Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithOrderProduct(_ orderProduct: OrderProduct) {
        self.orderProduct = orderProduct
        if let product = orderProduct.product {
            DispatchQueue.main.async {
                self.productImage.sd_setImage(with: URL(string: product.imagePath), placeholderImage: UIImage(named: ""))
                self.productImage.layer.cornerRadius = 10
                self.productImage.layer.masksToBounds = true
                self.productName.text = product.name
                self.productDescription.text = product.description
                self.productQuantity.text = "x\(orderProduct.quantity)"
                self.productPrice.text = "‎£\(String(format: "%.02f", product.price * Double(orderProduct.quantity)))"
                
                
            }
        }
    }
    
    @IBAction func productAddQuantity(_ sender: Any) {
        self.orderProduct.quantity += 1
        CacheManager.sharedInstance.cartOrderProducts.first(where: { $0.id == self.orderProduct.id })?.quantity = orderProduct.quantity
        self.updateQuantity()
        self.updateSubTotal()
        if self.cartUpdated != nil {
            self.cartUpdated!(true)
        }
    }
    @IBAction func productRemoveQuantity(_ sender: Any) {
        if self.orderProduct.quantity > 0 {
            self.orderProduct.quantity -= 1
        }
        CacheManager.sharedInstance.cartOrderProducts.first(where: { $0.id == self.orderProduct.id })?.quantity = orderProduct.quantity
        self.updateQuantity()
        self.updateSubTotal()
        if self.cartUpdated != nil {
            self.cartUpdated!(true)
        }
    }
    
    func updateQuantity() {
        DispatchQueue.main.async {
            self.productQuantity.text = "x\(self.orderProduct.quantity)"
        }
    }
    
    func updateSubTotal() {
        if let product = self.orderProduct.product {
            DispatchQueue.main.async {
                self.productPrice.text = "‎£\(String(format: "%.02f", product.price * Double(self.orderProduct.quantity)))"
            }
        }
    }
    
}
