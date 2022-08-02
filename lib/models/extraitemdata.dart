class ExtraItemData {
  int errorCode;
  String errorMessage;
  List<ExtraItemResponse> response;

  ExtraItemData({this.errorCode, this.errorMessage, this.response});

  ExtraItemData.fromJson(Map<String, dynamic> json) {
    errorCode = json['ErrorCode'];
    errorMessage = json['ErrorMessage'];
    if (json['Response'] != null) {
      response = <ExtraItemResponse>[];
      json['Response'].forEach((v) {
        response.add(new ExtraItemResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrorCode'] = this.errorCode;
    data['ErrorMessage'] = this.errorMessage;
    if (this.response != null) {
      data['Response'] = this.response.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ExtraItemResponse {
  int id;
  String addonName;
  String addonPrice;
  String addonType;
  int groupId;
  String groupName;
  int addonLimit;
  int itemGroupId;
  String titleName;

  ExtraItemResponse(
      {
        this.id,
        this.addonName,
        this.addonPrice,
        this.addonType,
        this.groupId,
        this.groupName,
        this.addonLimit,
        this.itemGroupId,
        this.titleName});

  ExtraItemResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addonName = json['addon_name'];
    addonPrice = json['addon_price'];
    addonType = json['addon_type'];
    groupId = json['group_id'];
    groupName = json['group_name'];
    addonLimit = json['addon_limit'];
    itemGroupId = json['item_group_id'];
    titleName = json['title_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['addon_name'] = this.addonName;
    data['addon_price'] = this.addonPrice;
    data['addon_type'] = this.addonType;
    data['group_id'] = this.groupId;
    data['group_name'] = this.groupName;
    data['addon_limit'] = this.addonLimit;
    data['item_group_id'] = this.itemGroupId;
    data['title_name'] = this.titleName;
    return data;
  }
}