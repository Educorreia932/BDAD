.mode columns
.headers on
.nullvalue NULL

PRAGMA FOREIGN_KEYS = ON;

-- Date of the Olympics event (that has an ID of value 41)
CREATE VIEW IF NOT EXISTS finalDate AS
    SELECT occurrenceDate FROM Event WHERE eventID = 41;

CREATE VIEW IF NOT EXISTS eventName AS
    SELECT name FROM Event WHERE eventID = 41;

SELECT day, IFNULL(numberOfComments, 0) as numberOfComments FROM (
    -- Generate a table with all 30 days
    (WITH RECURSIVE days(activityDate) AS (
        SELECT * FROM finalDate
        UNION ALL
        SELECT date(activityDate, '-1 day')
        FROM days
        WHERE julianday(activityDate) > (SELECT julianday(occurrenceDate) - 30 FROM finalDate)
    )

    SELECT days.activityDate AS day FROM days)

    LEFT JOIN

    -- Number of comments per day
    (SELECT activityDate as day, COUNT(commentID) AS numberOfComments 
        FROM (Comment INNER JOIN Activity ON Comment.commentID = Activity.activityID)
            WHERE activityText LIKE ("%" || (SELECT * FROM eventName) || "%") AND julianday(activityDate) >=
                (SELECT julianday(occurrenceDate) 
                    FROM (SELECT occurrenceDate
                        FROM Event WHERE eventID = 41)) - 30 
                            GROUP BY activityDate)
                            
    USING(day) 
) ORDER BY julianday(day)
