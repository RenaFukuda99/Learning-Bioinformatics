-- Represents rating by specific reviewer for specific passage
CREATE TABLE "rating" (
    id INT,
    passage_id INT,
    rating TEXT CHECK(rating in ("S","A","B","C","D","Unrankable")),
    reviewer SMALLINT NOT NULL,
    PRIMARY KEY(id),
    FOREIGN KEY(passage_id) REFERENCES passage(id)
);

-- Represents relevant passages from each book
CREATE TABLE "passage" (
    id INT,
    book_id INT NOT NULL,
    pov_char INT,
    body_text TEXT,
    PRIMARY KEY(id),
    FOREIGN KEY(book_id) REFERENCES book_id(id),
    FOREIGN KEY(pov_char) REFERENCES character(id)
);

-- Represents each book
CREATE TABLE "books" (
    id INT,
    title TEXT NOT NULL UNIQUE,
    PRIMARY KEY(id)
);

-- Represents each reviewer
CREATE TABLE "reviewer" (
    id INT,
    username TEXT NOT NULL UNIQUE,
    PRIMARY KEY(id)
);

-- Represents POV characters
CREATE TABLE "character" (
    id INT,
    first_name TEXT NOT NULL,
    last_name TEXT,
    PRIMARY KEY(id)
);
