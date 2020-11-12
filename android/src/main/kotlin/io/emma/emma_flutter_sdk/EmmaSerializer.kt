package io.emma.emma_flutter_sdk

import io.emma.android.model.EMMANativeAd
import io.emma.android.model.EMMANativeAdField
import io.emma.android.utils.EMMALog


object EmmaSerializer {

    fun  nativeAdToMap(nativeAd: EMMANativeAd): Map<String, Any>? {
        val nativeAdMap = HashMap<String, Any>()
        try {
            nativeAdMap["id"] = nativeAd.campaignID.toInt()
            nativeAdMap["templateId"] = nativeAd.templateId
            nativeAdMap["times"] = nativeAd.times.toInt()
            nativeAdMap["tag"] = nativeAd.tag
            nativeAdMap["showOn"] = if(nativeAd.showOnWebView()) "inapp" else "browser"
            nativeAdMap["params"] = nativeAd.params
            nativeAdMap["fields"] = nativeAdFieldsToMap(nativeAd.nativeAdContent)
        } catch (e: Exception) {
            EMMALog.e("Error parsing native ad", e)
            return null
        }
        return nativeAdMap
    }

    private fun nativeAdFieldsToMap(fields: Map<String, EMMANativeAdField>): Map<String, String> {
        val fieldsMap = HashMap<String, String>()
        for ((_, value) in fields.entries) {
            fieldsMap[value.fieldName] = value.fieldValue
        }
        return fieldsMap
    }
}