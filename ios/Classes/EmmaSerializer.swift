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
            "cta": nativeAd.getField("CTA"),
            "times": nativeAd.times,
            "tag": nativeAd.tag ?? NSNull(),
            "params": nativeAd.params ?? [:],
            "showOn": nativeAd.openInSafari ? "browser" : "inapp",
            "fields": nativeAd.nativeAdContent as? [String: Any] ?? []
            ]
    }
    
    static func inAppTypeFromString(inAppType: String) -> InAppType? {
        switch inAppType {
            case "startview":
                return .Startview
            case "nativeAd":
                return .NativeAd
            default:
                return nil
        }
    }
    
    static func inAppTypeToCommType(type: InAppType) -> EMMACampaignType? {
        switch type {
        case InAppType.Startview:
            return EMMACampaignType.campaignStartView
        case InAppType.NativeAd:
            return EMMACampaignType.campaignNativeAd
        default:
            return nil
        }
    }
}
            
