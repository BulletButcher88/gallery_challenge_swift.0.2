//
//  ViewController.swift
//  Gallery_Swift
//
//  Created by Mark Butcher on 7/12/20.
//
import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

struct Photo: Decodable {
    let id: String?
    let author: String?
    let width: Int?
    let heigth: Int?
    let url: String
    let download_url: String
}

class ViewController: UIViewController, UICollectionViewDataSource {
    
    var photos = [Photo]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self

        let url = URL(string: "https://picsum.photos/v2/list")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
           
            if error == nil {
                do {
                    self.photos = try JSONDecoder().decode([Photo].self, from: data!)
                }catch {
                    print("Error with API")
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomeCollectionViewCell
        
        cell.nameLbl.text = photos[indexPath.row].author?.capitalized
        cell.imageView.contentMode = .scaleAspectFill
        
        let defaultLink = photos[indexPath.row].download_url
        cell.imageView.downloaded(from: defaultLink)

        return cell
    }
}


