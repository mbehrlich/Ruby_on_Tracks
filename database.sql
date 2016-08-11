CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  username VARCHAR(255) NOT NULL
);

CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  color VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

INSERT INTO
  users (id, username)
VALUES
  (1, "Matt"),
  (2, "Michael"),
  (3, "Greg"),
  (4, "Anthony"),
  (5, "Aaron"),
  (6, "Forest"),
  (7, "Ryan");

INSERT INTO
  cats (id, name, color, owner_id)
VALUES
  (1, "Spot", "spotted", 1),
  (2, "Fluffy", "white", 4),
  (3, "Destroyer", "red", 6),
  (4, "Shiva", "black", 1);
