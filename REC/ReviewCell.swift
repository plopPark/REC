//
//  ReviewCell.swift
//  REC
//
//  Created by 박상준 on 2023/06/17.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var customRate: UILabel!
    
    @IBOutlet weak var review: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
