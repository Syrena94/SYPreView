//
//  ImgTableViewCell.swift
//  SYSwitf
//
//  Created by Syrena on 2019/10/23.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit

class ImgTableViewCell: UITableViewCell {
    var img:UIImageView!
    var url:String!{
        didSet{
            img.kf.setImage(with: URL.init(string: url))
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        img = UIImageView.init(frame: CGRect(x: 15, y: 10, width: 80, height: 80))
        img.contentMode = .scaleAspectFill
        img.layer.masksToBounds = true
        contentView.addSubview(img)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
