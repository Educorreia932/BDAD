.mode columns
.headers on
.nullvalue NULL

PRAGMA FOREIGN_KEYS = ON;

INSERT INTO Friendship('senderID', 'receiverID','state','date') VALUES(1,7,1,'2000-03-04');
INSERT INTO Friendship('senderID', 'receiverID','state','date') VALUES(3,7,1,'2000-03-04');

-- Friends of each user
CREATE VIEW IF NOT EXISTS friends AS
    SELECT * FROM (
            (SELECT senderID as source, receiverID as target
                FROM Friendship
                    WHERE state IS 1 
        UNION
            SELECT receiverID as source, senderID as target
                FROM Friendship
                    WHERE state IS 1)
    ) GROUP BY source, target;

SELECT source as User, target as Suggestion
FROM (SELECT *, source || target as conc
        FROM (SELECT f1.source, f2.target
            FROM friends f1
            JOIN friends f2
            ON f2.source = f1.target
            LEFT JOIN friends f3
            ON f3.source = f1.source
            AND f3.target = f2.target
        WHERE f2.target <> f1.source
            AND f3.target IS NULL)
    GROUP BY conc
    HAVING COUNT(*) > 1);

DELETE FROM Friendship WHERE senderID = 1 AND receiverID = 7 AND state = 1;
DELETE FROM Friendship WHERE senderID = 3 AND receiverID = 7 AND state = 1;