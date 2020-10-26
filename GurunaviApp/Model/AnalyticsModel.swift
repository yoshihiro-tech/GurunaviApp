//
//  AnalyticsModel.swift
//  GurunaviApp
//
//  Created by Yoshihiro Uda on 2020/10/26.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DoneCatchDataProtocol {
    
    func catchData(arrayData:Array<ShopData>,resultCount:Int)
}


class AnalyticsModel{
    
    var idoValue:Double?
    var keidoValue:Double?
    var urlString:String?
    
    var shopDataArray = [ShopData]()
    var doneCatchDataProtocol:DoneCatchDataProtocol?
    
    //ViewControllerから値を受け取る
    init(latitude:Double,longitude:Double,url:String) {
        
        idoValue = latitude
        keidoValue = longitude
        urlString = url
        
    }
    
    
    //JSON解析
    func setData(){
        
        //urlエンコーディング
        let encordeUrlString:String = urlString!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        AF.request(encordeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            
            print(response.debugDescription)
            
            switch response.result{
            
            case .success:
                do {
                    let json:JSON = try JSON(data: response.data!)
                    var totalHitCount = json["total_hit_count"].int
                    
                    if totalHitCount! > 50{
                        totalHitCount = 50
                    }
                    
                    for i in 0 ... totalHitCount! - 1{
                        
                        if json["rest"][i]["latitude"] != "" && json["rest"][i]["longitude"] != "" && json["rest"][i]["url"] != "" && json["rest"][i]["name"] != "" && json["rest"][i]["tel"] != "" && json["rest"][i]["image_url"]["shop_image1"] != ""{
                            
                            let shopData = ShopData(latitude: json["rest"][i]["latitude"].string, longitude: json["rest"][i]["longitude"].string, url: json["rest"][i]["url"].string, name: json["rest"][i]["name"].string, tel: json["rest"][i]["tel"].string, shop_image: json["rest"][i]["image_url"]["shop_image1"].string)
                            
                            self.shopDataArray.append(shopData)
                            
                        }else{
                            print("何かしらが空です")
                        }
                        
                    }
                    
                    self.doneCatchDataProtocol?.catchData(arrayData: self.shopDataArray, resultCount: self.shopDataArray.count)
                    
                } catch {
                    print("エラーです")
                }
                
                break
                
            case .failure:break
                
            }
        }
    }
    
}
