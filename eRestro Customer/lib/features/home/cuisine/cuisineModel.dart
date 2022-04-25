class CuisineModel {
  String? id;
  String? name;
  String? parentId;
  String? slug;
  String? image;
  String? banner;
  String? rowOrder;
  String? status;
  String? clicks;
 // List<Null>? children;
  String? text;
  State? state;
  String? icon;
  int? level;
  int? total;

  CuisineModel(
      {this.id,
        this.name,
        this.parentId,
        this.slug,
        this.image,
        this.banner,
        this.rowOrder,
        this.status,
        this.clicks,
      //  this.children,
        this.text,
        this.state,
        this.icon,
        this.level,
        this.total});

  CuisineModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentId = json['parent_id'];
    slug = json['slug'];
    image = json['image'];
    banner = json['banner'];
    rowOrder = json['row_order'];
    status = json['status'];
    clicks = json['clicks'];
    /*if (json['children'] != null) {
      children = <Null>[];
      json['children'].forEach((v) {
        children!.add(new Null.fromJson(v));
      });
    }*/
    text = json['text'];
    state = json['state'] != null ? new State.fromJson(json['state']) : null;
    icon = json['icon'];
    level = json['level'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['parent_id'] = this.parentId;
    data['slug'] = this.slug;
    data['image'] = this.image;
    data['banner'] = this.banner;
    data['row_order'] = this.rowOrder;
    data['status'] = this.status;
    data['clicks'] = this.clicks;
    /*if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }*/
    data['text'] = this.text;
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    data['icon'] = this.icon;
    data['level'] = this.level;
    data['total'] = this.total;
    return data;
  }
}

class State {
  bool? opened;

  State({this.opened});

  State.fromJson(Map<String, dynamic> json) {
    opened = json['opened'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['opened'] = this.opened;
    return data;
  }
}