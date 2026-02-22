
// Creates the database, its tables and relationships, and so on
const String createCategoryTable = '''
CREATE TABLE Category (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    Parent INTEGER,
    FOREIGN KEY (Parent) REFERENCES Category(ID) ON DELETE CASCADE
);
''';

const String createTaskTable = '''
CREATE TABLE Task (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Title TEXT NOT NULL,
    Status BOOLEAN NOT NULL DEFAULT FALSE,
    Category INTEGER,
    FOREIGN KEY (Category) REFERENCES Category(ID) ON DELETE CASCADE
);
''';