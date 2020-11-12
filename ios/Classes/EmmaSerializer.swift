//
//  EmmaSerializer.swift
//  
//
//  Created by Adrián Carrera on 12/11/2020.
//

import EMMA_iOS

class EmmaSerializer {
    static func nativeAdToDictionary(_ nativeAd: EMMANativeAd) -> [String: Any?] {
        return [
            "id": nativeAd.idPromo,
            "templateId": nativeAd.nativeAdTemplateId ?? "",
            "times": nativeAd.times,
            "tag": nativeAd.tag ?? NSNull(),
            "params": nativeAd.params ?? [:],
            "showOn": nativeAd.openInSafari ? "browser" : "inapp",
            "fields": nativeAd.nativeAdContent as? [String: Any] ?? []
            ]
    }
}
            
