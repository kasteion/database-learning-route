USE [SQL2]
GO

-- View data with clustered index (lname column is still sorted)
SELECT * FROM [SQL2].[dbo].[Phonebook]

-- Create another clustered index causes an issue (on fname) because you can only have one clustered index
CREATE CLUSTERED INDEX [Idx_Phonebook_phonebookid]
ON Phonebook(phonebookid ASC)

DROP INDEX [Phonebook].[Idx_Phonebook_lname]

-- Can create a single clustered index that has multiple columns
CREATE CLUSTERED INDEX [Idx_Phonebook_fname_lname]
ON [dbo].[Phonebook](lname ASC, fname ASC)

-- Example of non clustered index
CREATE NONCLUSTERED INDEX [NC_Idx_Phonebook_fname]
ON Phonebook(fname ASC)

-- After creation fo a non clustered index, the data is not sorted.
SELECT * FROM [SQL2].[dbo].[Phonebook]

-- Can create multiple non clustered index (on lname)

CREATE NONCLUSTERED INDEX [NC_Idx_Phonebook_phone]
ON Phonebook (phone ASC)

SELECT * FROM [SQL2].[dbo].[Phonebook]