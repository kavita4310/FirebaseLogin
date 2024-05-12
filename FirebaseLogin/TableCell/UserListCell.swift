//
//  UserListCell.swift
//  FirebaseLogin
//
//  Created by kavita chauhan on 12/05/24.
//

import UIKit

class UserListCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblDob: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
