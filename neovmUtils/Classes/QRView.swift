//
//  QRView.swift
//  neovmUtils_Tests
//
//  Created by Ross Krasner on 10/28/18.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public class QRView: UIView {
    lazy var imageView = UIImageView()
    public var code: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(imageView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    public func generate(code: String, foregroundColor: UIColor = .black, backgroundColor: UIColor = .white) {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            let data = Data(code.utf8)
            filter.setValue(data, forKey: "inputMessage")
            if let ciImage = filter.outputImage {
                let transformed = ciImage.transformed(by: CGAffineTransform.init(scaleX: 10, y: 10))
                let invertFilter = CIFilter(name: "CIColorInvert")
                invertFilter?.setValue(transformed, forKey: kCIInputImageKey)

                let alphaFilter = CIFilter(name: "CIMaskToAlpha")
                alphaFilter?.setValue(invertFilter?.outputImage, forKey: kCIInputImageKey)

                if let outputImage = alphaFilter?.outputImage {
                    imageView.tintColor = foregroundColor
                    imageView.backgroundColor = backgroundColor
                    imageView.image = UIImage(ciImage: outputImage, scale: 2.0, orientation: .up)
                        .withRenderingMode(.alwaysTemplate)
                }
                self.code = code
            }
        }
    }
}
