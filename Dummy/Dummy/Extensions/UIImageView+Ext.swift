//
//  UIImageView+Ext.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 23/06/2022.
//

import UIKit
import Nuke

extension UIImageView {
    func nukeLoadImage(
        url: URL?,
        placeHolder: UIImage? = defaultImage,
        complete:((UIImage?) -> Void)? = nil
    ) {
        guard let url = url else {
            image = placeHolder
            complete?(nil)
            return
        }
        let opt: ImageLoadingOptions = ImageLoadingOptions(placeholder: placeHolder, transition: .fadeIn(duration: 0.3))
        let rq = ImageRequest(url: url)
        Nuke.loadImage(with: rq, options: opt, into: self) { intermediateResponse, completedUnitCount, totalUnitCount in
            print("Progress: \(completedUnitCount)/\(totalUnitCount)")
        } completion: { [weak self] result in
            switch result {
            case .success(let imgRes):
                self?.image = imgRes.image
                complete?(imgRes.image)
            case .failure:
                self?.image = placeHolder
                complete?(nil)
            }
        }
    }
    
    func nuke_cancelImage() {
        Nuke.cancelRequest(for: self)
    }
}
