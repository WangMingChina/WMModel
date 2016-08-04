//
//  WMHotVideoModel.swift
//  WMModel
//
//  Created by kc on 16/8/3.
//  Copyright © 2016年 WM. All rights reserved.
//

import UIKit

 final class WMHotVideoModel: NSObject {

    var body:	[KCBodyModel]?
    var title:	String?
    var style:	String?
    var param:	String?
    var type:	String?
    var banner:	KCBannerModel?
    
    override func wm_modelPropertyClass() -> [String : NSObject.Type]? {
        
        return ["body":KCBodyModel.self,"banner":KCBannerModel.self]
    }

 

    
}

class KCBodyModel: NSObject {
    
    var cover   :NSURL?
    var title	:String?
    var param	:String?
    var play	:Int  = 0
    var goto	:String?
    var danmaku	:Int = 0
    var uri	    :NSURL?
     override func wm_modelPropertyClass() -> [String : NSObject.Type]? {
        
        return ["cover":NSURL.self,"uri":NSURL.self]
    }
 
}
class KCBannerModel: NSObject {
    
    var top :[KCBannerTopModel]?
    
    var bottom:	[KCBannerTopModel]?
    
     override func wm_modelPropertyClass() -> [String : NSObject.Type]? {
        
        return ["top":KCBannerTopModel.self,"bottom":KCBannerTopModel.self]
    }

    
}

class KCBannerTopModel: NSObject {
    var title	:String?
    var Hash	:String?
    var image	:NSURL?
    var uri	:NSURL?
     override func wm_modelPropertyClass() -> [String : NSObject.Type]? {
        
        return ["uri":NSURL.self,"image":NSURL.self]
    }

}

class KCExtModel: NSObject {
    
    var live_count:Int = 0
}