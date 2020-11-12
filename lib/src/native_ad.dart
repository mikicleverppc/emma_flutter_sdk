
class EmmaNativeAd {
  int id;
  String templateId;
  int times;
  String showOn;
  String tag;
  Map<String, dynamic> params;
  Map<String, String> fields;

  EmmaNativeAd() {
  }

  EmmaNativeAd.fromMap(Map<String, dynamic> json) {
    this.id =  json["id"];
    this.templateId = json["templateId"];
    this.times = json["times"];
    this.tag = json["tag"];
    this.showOn = json['showOn'];
    this.params = json["params"] != null? Map.from(json["params"]) : null;
    this.fields = Map.from(json["fields"]);
  }
}