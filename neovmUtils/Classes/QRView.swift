//
//  QRView.swift
//  neovmUtils_Tests
//
//  Created by Ross Krasner on 10/28/18.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

public class QRView: UIView {
    lazy var filter = CIFilter(name: "CIQRCodeGenerator")
    lazy var imageView = UIImageView()
    public var code: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    public func generateCode(_ string: String, foregroundColor: UIColor = .black, backgroundColor: UIColor = .white) {
        guard let filter = filter,
            let data = string.data(using: .isoLatin1, allowLossyConversion: false) else {
                return
        }

        filter.setValue(data, forKey: "inputMessage")

        guard let ciImage = filter.outputImage else {
            return
        }
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
        code = string
    }
}
