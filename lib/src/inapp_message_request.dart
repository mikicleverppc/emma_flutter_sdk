

import 'defines.dart';

class EmmaInAppMessageRequest {
  InAppType inAppType;
  // only nativeAd
  String templateId;
  bool batch;

  EmmaInAppMessageRequest(InAppType inAppType) {
    this.inAppType = inAppType;
  }

  Map<String, dynamic> toMap() {
    return {
      "inAppType": this.inAppType.toString().split(".")[1],
      "templateId": this.templateId ?? null,
      "batch": this.batch
    };
  }
}