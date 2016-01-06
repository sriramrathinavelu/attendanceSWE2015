//
//  ClassTableViewCell.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/23/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit

class ClassCell: UITableViewCell {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var course: Course! {
        didSet {
            codeLabel.text = course.getCourseKey()
            nameLabel.text = course.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
