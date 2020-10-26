//
//  ViewController.swift
//  GurunaviApp
//
//  Created by Yoshihiro Uda on 2020/10/26.
//

import UIKit
import MapKit
import Lottie

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate, DoneCatchDataProtocol {
    
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var animationView = AnimationView()
    
    let locationManager = CLLocationManager()
    var idoValue = Double()
    var keidoValue = Double()
    var apikey = "db6fd43240dc1d9ec7bc61e56136298f"
    
    var shopDataArray = [ShopData]()
    var totalHitCount = Int()
    var urlArray = [String]()
    var imageStringArray = [String]()
    var nameStringArray = [String]()
    var telArray = [String]()
    
    var annotation = MKPointAnnotation()
    var indexNumber = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUpdatingLocation()
        configureSubViews()
        
    }
    
    //Lottieを表示する(API呼び出し中)
    func startLoad(){
        
        animationView = AnimationView()
        let animation = Animation.named("1")
        animationView.frame = view.bounds
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
        
    }
    
    
    //位置情報を取得していいか許可
    func startUpdatingLocation(){
        
        locationManager.requestAlwaysAuthorization()
        
        let status = CLAccuracyAuthorization.fullAccuracy
        if status == .fullAccuracy{
            
            locationManager.startUpdatingLocation()
            
        }
    }
    
    
    //何が選択されているのかを取得する
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            
            break
        case .notDetermined, .denied, .restricted:
            
            break
        default:
            print("Unhandled case")
        }
        
        switch manager.accuracyAuthorization {
        case .reducedAccuracy: break
        case .fullAccuracy: break
        default:
            print("This should not happen!")
        }
    }
    
    
    //位置情報取得の精度
    func configureSubViews(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
        
    }
    
    
    //緯度経度取得(位置が変化するごとに呼ばれる)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        idoValue = latitude!
        keidoValue = longitude!
        
    }
    
    
    @IBAction func search(_ sender: Any) {
        
        textField.resignFirstResponder()
        
        startLoad()
        
        //検索文字列、経度緯度とぐるなびAPIKEYを用いてURLを作成
        let urlString = "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=\(apikey)&latitude=\(idoValue)&longitude=\(keidoValue)&range=3&hit_per_page=50&freeword=\(textField.text!)"
        
        //通信
        let analyticsModel = AnalyticsModel(latitude: idoValue, longitude: keidoValue, url: urlString)
        
        analyticsModel.doneCatchDataProtocol = self
        analyticsModel.setData()
        
    }
    
    
    func addAnnotation(shopData:[ShopData]){
        
        removeArray()
        
        for i in 0 ... totalHitCount - 1{
            
            //毎回初期化
            annotation = MKPointAnnotation()
            // ピンの位置
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(shopDataArray[i].latitude!)!, CLLocationDegrees(shopDataArray[i].longitude!)!)
            //タイトル、サブタイトル
            annotation.title = shopData[i].name
            annotation.subtitle = shopData[i].tel
            
            urlArray.append(shopData[i].url!)
            imageStringArray.append(shopData[i].shop_image!)
            nameStringArray.append(shopData[i].name!)
            telArray.append(shopData[i].tel!)
            mapView.addAnnotation(annotation)
        }
        
        textField.resignFirstResponder()
    }
    
    
    //アノテーション・配列初期化
    func removeArray(){
        
        mapView.removeAnnotations(mapView.annotations)
        urlArray = []
        imageStringArray = []
        nameStringArray = []
        telArray = []
        
    }
    
    
    func catchData(arrayData: Array<ShopData>, resultCount: Int) {
        
        //値が入ってきたのでアニメーション終了
        animationView.removeFromSuperview()
        
        //arrayData resultCountを受け取る
        shopDataArray = arrayData
        totalHitCount = resultCount
        
        //shopDataArrayの中身を取り出してアノテーションとして設置
        addAnnotation(shopData: shopDataArray)
        
    }
    
    
    //アノテーションがタップされた時に呼ばれるdelegateメソッド
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //情報をもとに詳細ページへ画面遷移
        indexNumber = Int()
        
        if nameStringArray.firstIndex(of: (view.annotation?.title)!!) != nil{
            
            indexNumber = nameStringArray.firstIndex(of: (view.annotation?.title)!!)!
            
        }
        
        performSegue(withIdentifier: "detailVC", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let detailVC = segue.destination as! DetailViewController
        detailVC.name = nameStringArray[indexNumber]
        detailVC.tel = telArray[indexNumber]
        detailVC.imageURLString = imageStringArray[indexNumber]
        detailVC.url = urlArray[indexNumber]
        
    }
    
}

