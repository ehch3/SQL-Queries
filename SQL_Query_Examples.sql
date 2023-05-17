-- Edmond C

-- Example 1
SELECT
    t.TITLE_ID as "Title ID",
    t.TYPE as "Book Type",
    a.AU_ID as "Author_ID",
    a.AU_FNAME || ' ' || a.AU_LNAME as "Author Name",
    a.STATE as "Author State",
    TO_CHAR((t.PRICE * t.TOTAL_SALES), '$9,999,999.99') as "Expected Revenue" 
FROM
    pb.TITLES t JOIN pb.TITLEAUTHOR ta on t.TITLE_ID = ta.TITLE_ID 
    JOIN pb.AUTHORS a on ta.AU_ID = a.AU_ID
WHERE
    ta.AU_ORD = 1
ORDER BY    
    t.TYPE DESC,
    "Author Name" ASC;

-- Example 2
SELECT
    st.STOR_ID as "Store ID",
    st.STOR_NAME as "Store Name",
    COUNT(sd.ORD_NUM) as "Number of Orders",
    COUNT(distinct sd.TITLE_ID) as "Number of Different Books sold",
    sum(sd.QTY) as "Number of Books sold",
    TO_CHAR(SUM(t.TOTAL_SALES * t.PRICE), '$9,999,999.99') as "Revenue"
FROM
    pb.STORES st JOIN pb.SALESDETAIL sd on st.STOR_ID = sd.STOR_ID
    JOIN pb.TITLES t on sd.TITLE_ID = t.TITLE_ID
GROUP BY
    st.STOR_ID , st.STOR_NAME
HAVING
    COUNT(sd.ORD_NUM) <=
        (
            SELECT
                COUNT(sd.ORD_NUM) / COUNT(DISTINCT s.STOR_ID)
            FROM
                pb.SALESDETAIL sd JOIN pb.STORES s on sd.STOR_ID = s.STOR_ID
        )
;

-- Example 3
SELECT
    t.title_id as "Title ID",
    t.title as "Book Title",
    COALESCE(t.price, 0) as "Price",
    RANK() over (ORDER BY t.price) as "Rank",
    DENSE_RANK() over (ORDER BY t.price) as "DenseRank"
    
FROM
    pb.TITLES t

WHERE 
    EXISTS 
    (
        SELECT *
        FROM pb.SALESDETAIL sd
        WHERE t.title_id = sd.title_id
    )
    
ORDER BY
    t.price FETCH FIRST 5 ROWS WITH TIES;

-- Example 4
SELECT
    p.pub_id as "Publisher ID",
    p.pub_name as "Publisher Name",
    TO_CHAR(COALESCE(sum(sd.QTY * t.PRICE), 0), '$9,999,999.99') as "Total Revenue",
    
    TO_CHAR(COALESCE(sum(
        CASE 
        WHEN t.type = 'business' then sd.QTY * t.PRICE
        ELSE 0
    END), 0), '$9,999,999.99') as "Bus Revenue"
    
FROM
    pb.PUBLISHERS p JOIN pb.TITLES t on p.pub_id = t.pub_id
    LEFT OUTER JOIN pb.SALESDETAIL sd on t.title_id = sd.title_id

GROUP BY
    p.pub_id, p.pub_name
;