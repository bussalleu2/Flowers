//
//  PhotoList.swift
//  unsplasher-sfy (iOS)
//
//  Created by Alba Bussalleu on 21/10/21.
//

import Foundation
import UIKit

private let minSpace: CGFloat = 16
private let pageSize: Int = 30

open class PhotosListViewController: UIViewController, ImageCollectionViewCellDelegate {
    func authorSelected(index: Int) {
        
    }
    

    @IBOutlet var colViewFlowers: UICollectionView!
 
    private var isFetching = false
    private var completion:((UIImage, String?) -> Void)?
    private var photoDownloader : URLSession?
    private var dataSource: [Photo] = []
    private let photoDLQueue:  OperationQueue = {
        $0.name = "unsplash.photoQueue"
        $0.qualityOfService = .utility
        return $0
    }(OperationQueue())



    override open func viewDidLoad() {
        super.viewDidLoad()
        let config = URLSessionConfiguration.default
        config.networkServiceType = .responsiveData
        config.sharedContainerIdentifier = "photodownloader"
        photoDownloader = URLSession(configuration: config, delegate: nil, delegateQueue: photoDLQueue)

        colViewFlowers.contentInset = UIEdgeInsets.init(top: 56, left: 0, bottom: 0, right: 0)
       
        requestPhotos()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }

     private func requestPhotos() {
        let currentPage = Int(dataSource.count / pageSize) + 1
        isFetching = true
       
         
         DataProvider.searchPhotos(query: Constants.App.IMAGE_SEARCH,
                                  page: currentPage,
                                  per_page: pageSize,
                                  completion: { (photos, errors) in

                self.isFetching = false
                guard errors == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self.dataSource.append(contentsOf: photos)
                    var indexes: [IndexPath] = []
                    for i in self.dataSource.count - photos.count ..< self.dataSource.count {
                        indexes.append(IndexPath(row: i, section: 0))
                    }
                    
                    self.colViewFlowers.insertItems(at: indexes)
                }
            })
        }
        
    

    override open func didReceiveMemoryWarning() {
        photoDownloader?.invalidateAndCancel()
        super.didReceiveMemoryWarning()
    }


 

    
    
}



extension PhotosListViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
 
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (self.view.frame.size.width - (3 * minSpace)) / 2
    
        return CGSize(width: cellSize, height: cellSize + 30)
    }
   
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: minSpace, bottom: 0, right: minSpace)
    }

 public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minSpace
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = dataSource[indexPath.row].getURLForQuality(quality: FlowersImageQuality.regular){
            let request = URLRequest(url: URL(string: url)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10.0)
            photoDownloader?.dataTask(with: request) { (data, response, error) in
                guard
                    let data = data,
                    let img = UIImage(data: data) else {
                        return
                }

                DispatchQueue.main.async {
                    self.completion?(img, url)
                    let detailPhotoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
                    
                    detailPhotoViewController.photoData = img
                    self.navigationController?.pushViewController(detailPhotoViewController, animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }.resume()

            
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if dataSource.count < 100 && !isFetching,
            let lastVisibleCell = colViewFlowers.visibleCells.last,
            let index = colViewFlowers.indexPath(for: lastVisibleCell), index.row > dataSource.count - 10 {
            requestPhotos()
        }
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
      
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell,
            indexPath.row < dataSource.count
            else {
                return UICollectionViewCell()
        }
        
        
       
        let photo = dataSource[indexPath.row]
      
        cell.index = indexPath.row
        cell.delegate = self
        cell.dataTask?.cancel()
        cell.imageView.image = nil
        
        cell.startAnimation()

        if let url = photo.getURLForQuality(quality: FlowersImageQuality.thumb),
         
            let realURL = URL(string: url) {
         
            let request = URLRequest(url: realURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10.0)
            cell.dataTask = photoDownloader?.dataTask(with: request) { (data, response, error) in
                guard
                    let data = data,
                    let img = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            cell.stopAnimation()
                        }
                        return
                }

                DispatchQueue.main.async {
                    cell.stopAnimation()
                    cell.imageView.image = img
                }
            }

            cell.dataTask?.resume()
        }

        return cell
    }
}


