//
//  String+NetworkAdd.swift
//  XXHNetWork
//
//  Created by icochu on 2019/9/25.
//  Copyright © 2019 Sniper. All rights reserved.
//

import UIKit
import CommonCrypto


extension String {
    func MD5String() -> String! {
        // CC_MD5 需要 #import <CommonCrypto/CommonDigest.h>
        let cStr = self.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return String(format: md5String as String)
    }
}
