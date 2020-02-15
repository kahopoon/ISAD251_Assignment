//
//  ShowOrdersTableViewCell.swift
//  Kaho Bar
//
//  Created by Johnson on 13/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit

class ShowOrdersTableViewCell: UITableViewCell {

    @IBOutlet weak var orderCreateDatetime: UILabel!
    @IBOutlet weak var orderItems: UILabel!
    @IBOutlet weak var orderUpdateDatetime: UILabel!
    @IBOutlet weak var orderTotalPrice: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithOrder(_ order: Order) {
        DispatchQueue.main.async {
            self.orderCreateDatetime.text = order.createDatetime
            self.orderUpdateDatetime.text = order.updateDatetime
            self.orderTotalPrice.text = "‎£\(String(format: "%.02f", order.totalPrice))"
            switch order.status {
            case .created:
                self.orderStatus.text = "CREATED"
                self.orderStatus.textColor = UIColor.white
            case .inProgress:
                self.orderStatus.text = "IN PROGRESS"
                self.orderStatus.textColor = UIColor.yellow
            case .delivered:
                self.orderStatus.text = "DELIVERED"
                self.orderStatus.textColor = UIColor.green
            default:
                self.orderStatus.text = "CANCELLED"
                self.orderStatus.textColor = UIColor.red
            }
            var itemsString:[String] = []
            for item in order.orderProducts {
                if let itemName = CacheManager.sharedInstance.products.first(where: { $0.id == item.id })?.name {
                    itemsString.append("\(itemName)    x \(item.quantity)")
                }
            }
            self.orderItems.text = itemsString.joined(separator: "\n")
        }
    }

}
