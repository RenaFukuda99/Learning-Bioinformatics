-- Get average rating of a book
SELECT AVG(r.rating)
FROM rating r
JOIN passages p ON r.passage_id = p.id
WHERE p.book_id = 1
GROUP BY p.book_id;

-- Get all ratings for a specific character
SELECT r.passage_id, r.rating
FROM ratings r
JOIN passages p ON r.passage_id = p.id
WHERE pov_char = 1;

-- Compare average ratings between reviewers for each book


-- Add rating
INSERT INTO "ratings" (passage, rating, reviewer)
VALUES ('', A, 'Glidus')

-- Add book
INSERT INTO "books" (itle)
VALUES ('The Winds of Winter')