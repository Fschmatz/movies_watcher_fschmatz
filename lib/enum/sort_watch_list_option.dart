enum SortOption {

  titleAsc(0, 'Title Asc', "title asc" ),
  titleDesc(1, 'Title Desc',  "title desc"),
  runtimeAsc(2, 'Runtime Asc',  "runtime asc"),
  runtimeDesc(3, 'Runtime Desc' ,  "runtime desc"),
  yearAsc(4, 'Year Asc' , "year asc"),
  yearDesc(5, 'Year Desc' , "year desc"),
  dateAddedAsc(6, 'Date Added Asc' ,  "dateAdded asc"),
  dateAddedDesc(7, 'Date Added Desc' , "dateAdded desc");

  const SortOption(this.id, this.name, this.sqlOrderBy );

  final num id;
  final String name;
  final String sqlOrderBy;

}
