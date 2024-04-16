//
//  UserTableViewCell.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 1/3/24.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbID: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
