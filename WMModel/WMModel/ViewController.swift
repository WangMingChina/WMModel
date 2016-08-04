//
//  ViewController.swift
//  WMModel
//
//  Created by kc on 16/8/3.
//  Copyright © 2016年 WM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        let jsonPath = NSBundle.mainBundle().pathForResource("bibi", ofType: "json") ?? ""
        
        let data = NSData(contentsOfFile: jsonPath) ?? NSData()
        
        let json = try! NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        
        if let dict = json as? [String:AnyObject],let dictArray = dict["data"] as? [[String:AnyObject]] {
            
            
            
            let models =  WMHotVideoModel.wm_models(dictArray) as! [WMHotVideoModel]
            
        
            
        }
        
        
    }
}

