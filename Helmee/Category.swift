//
//  Category.swift
//  GetAnAnswer
//
//  Created by Antoine Payan on 03/09/2016.
//  Copyright © 2016 IlouAntoine. All rights reserved.
//

import Foundation

class Category: NSObject, NSCoding {
	var id : Int;
	var title : String;
	var image : Int;
    var color : String;
    
    init(id: Int, title: String, image: Int, color: String) {
        self.id = id
        self.title = title
        self.image = image
        self.color = color
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "categoryId")
        aCoder.encode(title, forKey: "categoryTitle")
        aCoder.encode(image, forKey: "categoryImage")
        aCoder.encode(color, forKey: "categoryColor")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeInteger(forKey: "categoryId")
        title = aDecoder.decodeObject(forKey: "categoryTitle") as! String
        image = aDecoder.decodeInteger(forKey: "categoryImage")
        color = aDecoder.decodeObject(forKey: "categoryColor") as! String
    }
    
}
