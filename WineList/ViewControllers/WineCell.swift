//
//  WineCell.swift
//  WineList
//
//  Created by Jon Boling on 11/4/18.
//  Copyright © 2018 Walt Boling. All rights reserved.
//

import UIKit

class WineCell: UITableViewCell {
    
    var spacingConstantMedium: CGFloat = 10.0
    var spacingConstantLarge: CGFloat = 25.0

    var wineImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "WineListIconBW") // will prob have to set all of these values in the cellForRowAt code in WineListVC
        //imageView.clipsToBounds = true
        return imageView
    }()
    
    var wineNameLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Wine name"
        return label
    }()
    
    var yearAndTypeLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Wine type"
        return label
    }()
    
    var priceAndStoreLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Price + 'bought at' + store name"
        return label
    }()
    
    var thumbsUpOrDown: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "greenThumbsUpIcon")
        return imageView
    }()
    
    var thumbsBackground: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        view.backgroundColor = .white
        view.layer.cornerRadius = view.bounds.width / 2
        return view
    }()
    
    override func draw(_ rect: CGRect) {
        thumbsBackground.layer.cornerRadius = thumbsBackground.bounds.size.width / 2
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(wineImageView)
        self.addSubview(wineNameLabel)
        self.addSubview(yearAndTypeLabel)
        self.addSubview(priceAndStoreLabel)
        self.addSubview(thumbsBackground)
        self.thumbsBackground.addSubview(thumbsUpOrDown)
    }
    
    
    override func layoutSubviews() {
        wineImageView.layer.cornerRadius = 3
        wineImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -spacingConstantMedium).isActive = true
        wineImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        wineImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        wineImageView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: spacingConstantMedium).isActive = true
        
        wineNameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacingConstantMedium).isActive = true
        wineNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: spacingConstantLarge).isActive = true
        wineNameLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        wineNameLabel.rightAnchor.constraint(equalTo: wineImageView.leftAnchor, constant: spacingConstantMedium).isActive = true
        
        yearAndTypeLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacingConstantMedium).isActive = true
        yearAndTypeLabel.topAnchor.constraint(equalTo: wineNameLabel.bottomAnchor).isActive = true
        yearAndTypeLabel.rightAnchor.constraint(equalTo: wineImageView.leftAnchor, constant: spacingConstantMedium).isActive = true
        yearAndTypeLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        priceAndStoreLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacingConstantMedium).isActive = true
        priceAndStoreLabel.topAnchor.constraint(equalTo: yearAndTypeLabel.bottomAnchor).isActive = true
        priceAndStoreLabel.rightAnchor.constraint(equalTo: wineImageView.leftAnchor, constant: spacingConstantMedium).isActive = true
        priceAndStoreLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        thumbsBackground.rightAnchor.constraint(equalTo: wineImageView.rightAnchor).isActive = true
        thumbsBackground.bottomAnchor.constraint(equalTo: wineImageView.bottomAnchor).isActive = true
        thumbsBackground.heightAnchor.constraint(equalToConstant: 25).isActive = true
        thumbsBackground.widthAnchor.constraint(equalTo: thumbsBackground.heightAnchor).isActive = true
        
        thumbsUpOrDown.leftAnchor.constraint(equalTo: thumbsBackground.leftAnchor).isActive = true
        thumbsUpOrDown.rightAnchor.constraint(equalTo: thumbsBackground.rightAnchor).isActive = true
        thumbsUpOrDown.topAnchor.constraint(equalTo: thumbsBackground.topAnchor).isActive = true
        thumbsUpOrDown.bottomAnchor.constraint(equalTo: thumbsBackground.bottomAnchor).isActive = true
        

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
