# WHAT IS AN INDEX?

An index can be best described as a pointer to data in a table. An index in a database is very similar to an index in the back of a book or the phone book. Indexes are created on the table or the view.

# PURPOSE OF AN INDEX

The purpose of an index is to retrieve data from a table efficiently and fast.

# TYPES OF INDEXES

## CLUSTERED INDEXES

Clustered indexes sort the data rows in the table or view based on their key values, as such there can be only one clustered index per table. When a table does not have an index it is referred to as a **heap**. when you create a clustered index, it **does not require any additional disk space**.

## NON-CLUSTERED INDEXES

A Non-clustered index have a structure separate from the data rows, much like the index in back of a book; and as such **does require disk space**, as it's a separate object. A nonclustered index contains a pointer to the data row that contains the key value. For a heap, a row locator is a pointer to the row. For a clustered table, the row locator is the clustered index key.

## COMPOSITE INDEXES

A composite index is an index on two or more columns of a table. A composite index can be created both on a clustered and non-clustered index. Note, when creating a composite index the order of columns in the index is important for performance. Columns that will always mentioned in a query should be place first.

## OTHER LESS USED INDEXES (IT DEPENDS)

- Covering Indexes
- Full-Text
- Filtered Indexes
- Column-based Indexes
- Spatial
- XML

# CREATING INDEXES USING TSQL

```
CREATE INDEX index_name
ON table_name (column_name)

CREATE UNIQUE INDEX index_name
ON table_name (column_name)

CREATE NONCLUSTERED INDEX [index_name]
ON table_or_view_name ([column_name] ASC|DESC)

DROP INDEX index_name ON table_name

CREATE CLUSTERED INDEX index_name
ON table_name (column_name)
```

# WHEN SHOULD INDEXES BE CONSIDERED AND WHAT FACTORS INFLUENCE CREATION OF INDEXES?

- When the table is large in size (row count) (Contains millions if not 100's millions rows).

- When the table is used frequently (The table is used more than just infrequently)

- When the columns are frequently used in the WHERE clause (The query against the database has where clause)

- Columns that are frequently references in the ORDER BY and GROUP BY clauses (If you're sorting data, then its beneficial)

- Indexes should be created on columns with a high number of unique values (Create indexes on columns that are all virtually unique such as integer)

- Create single column index on sigle where clause query (If the where clause has a single column then create a single index)

- Create a multiple column index on multiple where clause query (If the where clause has multiple columns then create multiple index)

- Build index on columns of integer type (Integer takes less space to store, which means the query will be faster)

- The order of the composite index matters, so place the column in the index as with the where clause (Use the column with the lowest cardinality first, and the column with the highest cardinality last, which means keep the unique column first and less unique column last -- select distinct col1 from table)

- Testing is the key in determining what will work for your environment. Play with different combinations of indexes, no indexes, single-column indexes, and composite indexes.

# WHEN SHOULD INDEXES BE AVOIDED?

- Indexes should not be used on small tables (Smaller tables do better with a table scan)

- Indexes should not be used on columns that contain a high number of NULL values (Maintenance on the index can become excessive)

- Don't use an index that will return a high percentage of data (few distinct values such as gender)

- Creating indexes come with a cost
    - Indexes take up disk space
    - INSERT, UPDATE, and DELETE operations become slower, since the database system need to update the values in the table, and it also needs to update the indexes.

# INDEX FRAGMENTATION (REBUILD OR REORGANIZE AN INDEX)

- When Index fragmentation occurs should you reorganize or rebuild a fragmented index (it depends).}

- Whenever an insert, update, or delete operations occur against the underlying data, SQL automatically maintains indexes.

- These operation cause index fragmentation and can cause performance issues.

- Framentation exists when indexes have pages in which the logical ordering, based on the key value, does not match the physical ordering inside the data file.

- When you Rebuild an index SQL drops and re-creates the index and removes fragmentation, reclaims disk space by compacting and reorders the index rows in contiguous pages.

- When you Reorganize an index it defragments the leaf level of clustered and non clustered indexes on tables and views by physically reordering the leaf-level.

- The system function sys.db_db_index_physical_stats, allows you to detect fragmentation.

- If avg_framentation_in_percent value
    - More than 5% and Less or equal 30% REORGANIZE
    - More than 30% REBUILD

- Rebuild an index can be executed online or offline.
- Reorganizing an index is always executed online.