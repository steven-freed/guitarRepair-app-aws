//
//  AboutViewController.swift
//  guitar-repair
//
//  Created by steven freed on 6/5/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // sample images
    let images: [UIImage] = [#imageLiteral(resourceName: "guitar1"), #imageLiteral(resourceName: "guitar2"), #imageLiteral(resourceName: "guitar3"), #imageLiteral(resourceName: "guitar4")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension AboutViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = images[indexPath.row]
        
        return cell
    }

}
