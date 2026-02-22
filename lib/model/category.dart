class Category {
    int? id;
    String name;
    int? parent;

    Category({this.id, required this.name, this.parent});

    // Methods for restructuring data
    Map<String, dynamic> toMap() {
        return {
            'ID'    : id,
            'Name'  : name,
            'Parent': parent,
        };
    }

    // Creates the model
    factory Category.fromMap(Map<String, dynamic> map) {
        return Category(
            id    : map['ID'],
            name  : map['Name'],
            parent: map['Parent'],
        );
    }
}