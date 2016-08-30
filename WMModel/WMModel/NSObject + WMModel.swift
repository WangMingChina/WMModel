//
//  NSObject + WMModel.swift
//
//
//  Created by kc on 16/8/1.
//  Copyright © 2016年 凯创信息技术服务有限公司. All rights reserved.
//

import UIKit
/// - 使用字典转模型的nsobject的子类不要重新写一个构造器不然会出fatal error: use of unimplemented initializer 'init()' for class '字典转模型.KCModel'
extension NSObject {
    ///获取NSObject子类的属性列表
    static func attributeList() -> [String] {
        var arr = [String]()
        var count:UInt32 = 0
        func list(cls:NSObject.Type){
            
            let property = class_copyPropertyList(cls, &count)
            
            (0..<count).forEach { (number) in
                
                let pro = property[Int(number)]
                let str = property_getName(pro)
                
                if  let string = String(CString: str, encoding: NSUTF8StringEncoding) {
                    
                    arr.append(string)
                }
            }
            
            if let superCls = cls.superclass() where superCls != NSObject.self {
                
                if let superCls =  superCls as? NSObject.Type  {
                    
                    list(superCls)
                }
            }
            
            free(property)
        }
        
        list(self)
        
        return arr
    }
    /**
     model有嵌套类型属性,就返回此属性的的类型如 ["model":WMModel]
     
     - returns: 
     */
    func wm_modelPropertyClass()->[String:NSObject.Type]?{
        return nil
    }
  
    func Class() -> NSObject.Type{
    
        let cls = self.classForCoder as! NSObject.Type

        return cls
    }
    
    class func wm_models(obj:AnyObject?)->[NSObject]{
        
        
        
        guard let arr = obj as? [[String:AnyObject]] else { return []}
        
        
        return arr.flatMap({ return self.wm_model($0) })
    }

    /**
     模型json化
     
     - returns:
     */
    func wm_jsonPrettyStringEncoded() -> String? {
        
        let dict = wm_dict()
        
        guard NSJSONSerialization.isValidJSONObject(dict) else { return nil }
        
        do{
            
            let date = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
            return String(data: date, encoding: NSUTF8StringEncoding)
        }catch {
            return nil
        }
    }
    
    /**
     使用这个方法如果有嵌套模型就要重写wm_modelPropertyClass方法
     - returns:
     */
    func wm_dict() -> [String:AnyObject] {
        
        guard !(self is NSURL) else {  return [:]  }
        guard !(self is NSDate) else {  return [:]  }
        guard !(self is NSArray) else {  return [:]  }
        guard !(self is NSDictionary) else {  return self as? [String:AnyObject] ?? [:]}
        
        var dict = [String:AnyObject]()
        let arr = (self.classForCoder).attributeList()
        let attribute = wm_modelPropertyClass()
        arr.forEach { (propery) in
            
            if attribute?[propery] != nil{
    
                if let zi = self.valueForKey(propery) as? NSObject {
                    
                    if zi is NSURL {
                    
                        dict[propery] = dictString(zi)
                        
                    }else if  zi is NSDate {
                    
                        ///暂时不处理
                       // dict[propery] = dictString(zi)
    
                    }else if  zi is NSNull {

                        dict[propery] = nil
                    }else if let  zi = zi as? [NSObject] {
                        
                        let arr:[[String:AnyObject]] = zi.flatMap({ return $0.wm_dict() })
                        
                        dict[propery] = arr
                    }else {
                        
                        dict[propery] = zi.wm_dict()
                    }
                    
                }
                
            }else{
                
                if let value = self.valueForKey(propery) {
                    
                    
                    dict[propery] = value
                }
                
            }
        }
        return dict
        
    }
    /**
     字典转模型,  使用这个方法如果有嵌套模型就要重写wm_modelPropertyClass方法否则请使用这个方法
     
     - parameter json: json
     
     - returns: self
     */
    class func wm_model(json:AnyObject?) -> Self {
        
        
        let dict = objecDict(json)
        let mo = self.init()
        let obj = mo as NSObject
        let properList = attributeList()
        let attribute = mo.wm_modelPropertyClass()
        for propery in properList {
            
            if let cls = attribute?.value(propery) {
                
                if cls is NSURL.Type {
                    
                    let url = dictString(dict?.value(propery))?.url
                    
                    tryErroer({
                        
                        obj.setValue(url, forKey: propery)
                        
                        }, { (error) in
                            print(error)
                    })
                }else{
                    guard let value = dict?.value(propery) else {
                        
                        continue
                    }
                    
                    if value is [String:AnyObject] {
                        
                        tryErroer({
                            obj.setValue(cls.wm_model(dict?.value(propery) as? [String:AnyObject]), forKey: propery)
                            }, { (error) in
                                
                                print("\(self) error == \(error)")
                        })
                    }else if let arr = value as? [[String:AnyObject]]{
                        
                        
                        
                        let array = arr.flatMap{  return cls.wm_model($0) }
                        
                        tryErroer({
                            
                            obj.setValue(array, forKey: propery)
                            }, { (error) in
                                
                                print("\(self) error == \(error)")
                        })
                        
                    }
                }
            }else{
                guard let value = dict?.value(propery) else {
                    
                    continue
                }
                setValue(obj, value: value, propery: propery)
            }
        }
        return mo
        
    }
    /**
     字典转模型,  使用这个方法如果有嵌套模型就要重写wm_modelPropertyClass方法
     
     - parameter json: json
     */
    func wm_setValues(json:AnyObject?){
        
        let dict = objecDict(json)
        let properList = self.Class().attributeList()
        let attribute = self.wm_modelPropertyClass()
        for propery in properList {
            
            if let cls = attribute?.value(propery) {
                
                if cls is NSURL.Type {
                    
                    let url = dictString(dict?.value(propery))?.url
                    
                    tryErroer({
                        
                        self.setValue(url, forKey: propery)
                        
                        }, { (error) in
                            print(error)
                    })
                }else{
                    guard let value = dict?.value(propery) else {
                        
                        continue
                    }
                    
                    if value is [String:AnyObject] {
                        
                        tryErroer({
                            self.setValue(cls.wm_model(dict?.value(propery) as? [String:AnyObject]), forKey: propery)
                            }, { (error) in
                                
                                print("\(self) error == \(error)")
                        })
                    }else if let arr = value as? [[String:AnyObject]]{
                        
                        
                        
                        let array = arr.flatMap{  return cls.wm_model($0) }
                        
                        tryErroer({
                            
                            self.setValue(array, forKey: propery)
                            }, { (error) in
                                
                                print("\(self) error == \(error)")
                        })
                        
                    }
                }
            }else{
                guard let value = dict?.value(propery) else {
                    
                    continue
                }
                self.Class().setValue(self, value: value, propery: propery)
            }
        }
      
        
    }
    
    //MARK: /*--------不需要重写wm_modelPropertyClass方法-------------------------*/
    class func wm_model(json:AnyObject?,propertyClass:[String:NSObject.Type]?)->Self {
        let mo = self.init()
        let obj = mo as NSObject
        let properList = attributeList()
        let jsonDict = objecDict(json)
        for propery in properList {
            if let cls = propertyClass?.value(propery) {
                if cls is NSURL.Type {
                    let url = dictString(jsonDict?.value(propery))?.url
                    tryErroer({
                        obj.setValue(url, forKey: propery)
                        
                        }, { (error) in
                            
                            print(error)
                    })
                }else{
                    
                    tryErroer({
                        var dict = propertyClass
                        dict?[propery] = nil
                        obj.setValue(cls.wm_model(jsonDict?.value(propery), propertyClass: dict), forKey: propery)
                        }, { (error) in
                            
                            print("\(self) error == \(error)")
                    })
                    
                }

            }else{
                guard let value = jsonDict?.value(propery) else {
                    continue
                }
               
                setValue(obj, value: value, propery: propery)
            }
        }
        return mo
    }
    
    func wm_dict(propertyClass:[String:NSObject.Type]?) -> [String:AnyObject] {
        
        guard !(self is NSURL) else {  return [:]  }
        guard !(self is NSDate) else {  return [:]  }
        guard !(self is NSArray) else {  return [:]  }
        guard !(self is NSDictionary) else {  return self as? [String:AnyObject] ?? [:]}
        var dict = [String:AnyObject]()
        let arr = (self.classForCoder).attributeList()
        var attribute = propertyClass
        arr.forEach { (propery) in
            
            if attribute?[propery] != nil{
                
                if let zi = self.valueForKey(propery) as? NSObject {
                    
                    if zi is NSURL {
                        
                        dict[propery] = dictString(zi)
                        
                    }else if  zi is NSDate {
                        
                        
                        dict[propery] = dictString(zi)
                        
                    }else if  zi is NSNull {
                        
                        
                        dict[propery] = nil
                    }else{
                        attribute?[propery] = nil
                        dict[propery] = zi.wm_dict(attribute)
                    }
                }
                
            }else{
                tryErroer({
                    
                        if let value = self.valueForKey(propery) {
                            dict[propery] = value
                        }
                    
                    }, { (error) in
                        
                     print(error)
                })
                
            }
        }
        return dict

    }
    
    private static func setValue(obj:NSObject,value:AnyObject,propery:String){
    
        let name = obj.valueForKey(propery)
        let className =  NSStringFromClass(self as NSObject.Type)
        ///String,array ,dictionary,url,类型
        if name is String? {
            
            if value is String {
                
                tryErroer({
                    obj.setValue(value, forKey: propery)
                    
                    }, { (error) in
                        
                        print("\(className)属性\(name)类型不是String,而字典键对应的\(name)的值是String类型")
                })
            }else if value is [AnyObject]{
                tryErroer({
                    obj.setValue(value, forKey: propery)
                    
                    }, { (error) in
                        
                        print("\(className)属性\(name)类型不是数组类型,而字典键对应的\(name)的值是数组类型")
                        
                })
                
            }else if value is [String:AnyObject]{
                
                
                tryErroer({
                    
                    obj.setValue(value, forKey: propery)
                    
                    }, { (error) in
                        
                        print("\(className)属性\(name)类型不是字典类型,而字典键对应的\(name)的值是字典类型")
                })
                
            }else if value is NSNumber{
                
                tryErroer({
                    obj.setValue(dictString(value), forKey: propery)
                    
                    }, { (error) in
                        
                        print("\(className)属性\(name)类型不是基本数据类型,而字典键对应的\(name)的值是基本数据类型")
                })
            }else if value is UIResponder {
                
                tryErroer({
                    obj.setValue(value, forKey: propery)
                    
                    }, { (error) in
                        
                        print("\(className)属性\(name)类型和字典键对应的\(name)的值是类型不一样")
                })
                
            }
            //基础类型
        }else if name is NSNumber? {
            
            if value is Double {
                
                let num = dictString(value)?.double() ?? 0
                obj.setValue(num, forKey: propery)
            }else if value is CGFloat{
                
                let num = dictString(value)?.CG() ?? 0
                obj.setValue(num, forKey: propery)
            }else if value is Int{
                
                let num = dictString(value)?.int() ?? 0
                obj.setValue(num, forKey: propery)
            }else if value is String{
                
                let num = value
                obj.setValue(num, forKey: propery)
            }
        }
    }
}
//MARK: extension 全局函数
func dictString(obj:AnyObject?) -> String? {
    
    if obj is String? {
        
        return obj as? String
    }
    guard let obj = obj else { return nil }
    
    return String(obj)
}
func objecDict(obj:AnyObject?) ->[String:AnyObject]? {

    if let dict = obj as? [String:AnyObject] {
        return  dict
    }else {
        
        var data:NSData?
        
        if let string = obj as? String {
            
            data = string.dataUsingEncoding(NSUTF8StringEncoding)
        }
        if obj is NSData {
        
            data = obj as? NSData
        }
        guard let stringData = data else { return nil }
        do{
            if let dict = try NSJSONSerialization.JSONObjectWithData(stringData, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject] {
                return  dict
            }else{
                return nil
            }
        }catch {
            return nil
        }
    }
}
func objectSelf<T>(objec:Any)->T{return objec as! T}
func objectSelf<T>(objec:AnyObject)->T{return objec as! T}
func objectSelf<T>(objec:AnyClass)->T.Type{
    
    return objec as! T.Type

}
func objectArray<T>(object:AnyObject) -> [T]{return object as! [T]}
//MARK: KCDigitalTable 基础数值类型相关转换
extension String :KCDigitalTable{
    var url:NSURL?{
        return NSURL(string: self)
    }
}
extension Int    :KCDigitalTable{}
extension CGFloat:KCDigitalTable{}
extension Double :KCDigitalTable{}
extension Float  :KCDigitalTable{}
protocol KCDigitalTable {
    func digital() -> CGFloat
    func CG()    -> CGFloat
    func double()->Double
    func int()   ->Int
    func string()->String
    func bool()  -> Bool
}
extension KCDigitalTable {
    func string()->String {
        
        return "\(self)"
    }
    func bool() -> Bool {
        if self.int() != 0 {
            
            return true
        }
        return false
    }
    func digital() -> CGFloat{
        return CGFloat(Double(self.string()) ?? 0)
    }
    func CG() -> CGFloat {
        return self.digital()
    }
    func double() ->Double {
        return Double(self.digital())
    }
    func int() ->Int {
        return Int(self.digital())
    }
}
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex   = self.startIndex.advancedBy(r.endIndex)
            return self[startIndex..<endIndex]
        }
    }
}
extension Dictionary{
    /**
     忽略字典的Key大小写取值
     
     - parameter key: 键
     
     - returns:
     */
    func value(key:String) -> Value? {
        
        if (self[key as! Key] != nil) {
            
            return self[key as! Key]
        }else if (self[key.lowercaseString as! Key] != nil) {
        
            return self[key.lowercaseString as! Key]
        }else if (self[key.uppercaseString as! Key] != nil) {
            
            return self[key.uppercaseString as! Key]
        }else if (self[key.capitalizedString as! Key] != nil) {
            
            return self[key.capitalizedString as! Key]
        }
        return nil
    }

}
