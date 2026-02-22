class Task {
    int? id;
    String title;
    bool status;
    int? category;

    Task({this.id, required this.title, this.status = false, this.category});

    Map<String, dynamic> toMap() {
        return {
            'ID'      : id,
            'Title'   : title,
            'Status'  : status ? 1 : 0,
            'Category': category,
        };
    }

    factory Task.fromMap(Map<String, dynamic> map) {
        return Task(
            id      : map['ID'],
            title   : map['Title'],
            status  : (map['Status'] ?? 0) == 1,
            category: map['Category'],
        );
    }
}