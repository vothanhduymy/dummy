//
//  UserTableViewCell.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 22/06/2022.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowVw: UIView!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var imgPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowVw.dropShadow()
    }
    
    func reloadData(_ userListItem: UserListItem) {
        lblFirstName.text = userListItem.firstName
        lblLastName.text = userListItem.lastName
        if let url = URL(string: userListItem.picture) {
            imgPicture.download(from: url, placeholder: defaultImage)
        }
    }
}
