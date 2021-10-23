//
//  MainMenuVC.swift
//  My Recipe
//
//  Created by Adham Thabet on 01/10/2021.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit



class MainMenuViewController: UIViewController{
    
    @IBOutlet weak var posterTemplateCollectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var filterbtnView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var welcomingLabel: UILabel!
    
    
    var posterArray = [PosterTemplateManager]()
    var categoiesArray = [String]()
    var selectedDish:PosterTemplateManager?
    var arraySetup = ArriesSetup()
    var selectedCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAvatar.layer.cornerRadius = userAvatar.frame.height / 2
        userAvatar.clipsToBounds = true
        
        filterbtnView.layer.cornerRadius = 10
        
        posterTemplateCollectionView.delegate = self
        posterTemplateCollectionView.dataSource = self
        
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        
        configureInitialData()
        configureUserInfo()
        
    }
    
    func configureUserInfo (){
        if GIDSignIn.sharedInstance.currentUser != nil{
            if let userProfile = GIDSignIn.sharedInstance.currentUser!.profile{
                userNameLbl.text = userProfile.givenName
                if let safeImgURL = userProfile.imageURL(withDimension: 320){
                    userAvatar.downloaded(from: safeImgURL)
                }
            }
        }else{
            if let fbProfile = Profile.current{
                userNameLbl.text = fbProfile.name
                if let safeImageURL = fbProfile.imageURL{
                    userAvatar.downloaded(from: safeImageURL)
                }
            }
        }
    }
    
    
    func configureInitialData(){
    
        posterArray = arraySetup.setupPosterTemplateArray()
        categoiesArray = arraySetup.setupCategoriesArray()
        
        let colorOne = #colorLiteral(red: 0.3960784314, green: 0.7098039216, blue: 0.7843137255, alpha: 1)
        let colorTwo = #colorLiteral(red: 0.6352941176, green: 0.9019607843, blue: 0.8392156863, alpha: 1)
        let filterGradeintLayer = CAGradientLayer()
        filterGradeintLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        filterGradeintLayer.startPoint = CGPoint(x: 1, y: 1)
        filterGradeintLayer.endPoint = CGPoint(x: 0, y: 0)
        filterGradeintLayer.frame.size = filterbtnView.frame.size
        filterGradeintLayer.cornerRadius = 10
        filterbtnView.layer.insertSublayer(filterGradeintLayer, at: 0)
        
    }
    
}


//MARK:- CollectionView Delegate & Data Source Methods

extension MainMenuViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.posterTemplateCollectionView{
            return  posterArray.count
        }else{
            return  categoiesArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.posterTemplateCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterTemplateCell", for: indexPath) as! PosterCollectionViewCell
            let posterTemp  = posterArray[indexPath.row]
            
            cell.configurePosterTemplate(dishName: posterTemp.foodName, dishImage: posterTemp.plateImage, dishVerticalImage: posterTemp.verticalImage, dishReviews: posterTemp.reviews, dishTime: posterTemp.time, dishDiffculity: posterTemp.diffculity, bottomColor: posterTemp.bottomColor, topColor: posterTemp.topColor, cellBounds: cell.bounds)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
            let category = categoiesArray[indexPath.row]
            cell.categoryTitle.text = category
            cell.contentView.layer.cornerRadius = 12
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == posterTemplateCollectionView{
            return CGSize(width: self.view.frame.width*0.60, height: collectionView.frame.height)
        }else{
            return CGSize(width: self.view.frame.width*0.3, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == posterTemplateCollectionView{
            let selectedItem = posterArray[indexPath.row]
            selectedDish = selectedItem
            performSegue(withIdentifier: "mainMenuToDishDetailsSegue", sender: self)
        }else{
            let selectedItem = categoiesArray[indexPath.row]
            selectedCategory = selectedItem
            performSegue(withIdentifier: "mainMenuToCategoriesSegue", sender: self)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainMenuToDishDetailsSegue"{
            let destinationVC = segue.destination as! DishDetailsControllerView
            destinationVC.selectedDish = self.selectedDish
        }
        if segue.identifier == "mainMenuToCategoriesSegue"{
            let destinationVC = segue.destination as! CategoriesViewController
            destinationVC.selectedCategory = self.selectedCategory
            destinationVC.allDishes = self.posterArray
        }
    }
    
    
}
