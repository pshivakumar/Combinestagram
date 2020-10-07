/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import ReactiveSwift
import RxCocoa

class MainViewController: UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [] )
    private var imageCache = [Int]()
    
    // MARK: - View Controller life cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images.subscribe(onNext: { previewImages in
            self.updateUI(photos: previewImages)
            
            self.imagePreview.image = UIImage.collage(images: previewImages, size: self.imagePreview.frame.size)
        }).disposed(by: bag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Resources: \(RxSwift.Resources.total)")
    }
    
    // MARK: - Actions and func -
    
    func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    @IBAction func actionClear() {
        images.accept([])
    }
    
    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        
//        PhotoWriter.save(image)
//            .subscribe(onError: { [weak self] error in
//                self?.showMessage("Error", description: error.localizedDescription)
//                }, onCompleted: { [weak self] in
//                    self?.showMessage("Saved")
//                    self?.actionClear()
//            })
//            .disposed(by: bag)
        
        PhotoWriter.save(image).subscribe(onNext: { id in
            print(id)
        }, onError: { [weak self] error in
            self?.showMessage("Error", description: error.localizedDescription)
        }, onCompleted: { [weak self] in
            self?.showMessage("Saved")
            self?.actionClear()
            }).disposed(by: bag)
    }
    
    @IBAction func actionAdd() {
//        let newImages = images.value + [UIImage(named: "IMG_1907.jpg")!]
        let photosViewController = storyboard!.instantiateViewController( withIdentifier: "PhotosViewController") as! PhotosViewController
        
        photosViewController.selectedPhoto.subscribe(onNext: { selectedImage in
            self.images.accept(self.images.value + [selectedImage])
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("Completed")
        }){
            print("Completed all photos")
        }.disposed(by: bag)
        

        navigationController!.pushViewController(photosViewController, animated: true)
        
//        images.accept(newImages)
    }
    
    private func updateNavigationIcon() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                           style: .done,
                                                           target: nil,
                                                           action: nil)
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        showAlert(title: title, description: description)
            .subscribe()
            .disposed(by: bag)
    }
}
