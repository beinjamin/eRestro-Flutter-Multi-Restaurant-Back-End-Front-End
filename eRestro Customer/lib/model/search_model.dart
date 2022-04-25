
class SearchModel {
  int? id;
  String? title;


  SearchModel(
      {this.id,
        this.title,});
}

List<SearchModel> searchList = [
  SearchModel(
    id: 1,
    title: "Vegetarian",
  ),
  SearchModel(
    id: 2,
    title: "Rating 4+",
  ),
  SearchModel(
    id: 1,
    title: "Cost: Low to High",
  ),
];
