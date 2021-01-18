USE [SQL2]
GO

CREATE TABLE [dbo].[PhoneBook](
    PhoneBookID int NULL,
    lname varchar(50) NULL,
    fname varchar(50) NULL,
    phone varchar(50) NULL
) ON [PRIMARY]
GO

-- Insert 1000 Records

-- View the 1000 records. Notice that the last name is not in any particular order
SELECT * FROM Phonebook

-- Insert record into phonebook table and notice the row is inserted after 1000 rows, as there is no index and the lname is in no particular order
INSERT INTO Phonebook VALUES (1001, 'Abba', 'Sara', '555-1212')

-- Repeat with another record
INSERT INTO Phonebook VALUES (1002, 'Turner', 'Mike', '805-555-1212')
SELECT * FROM Phonebook

-- Create a clustered index on table phonebook and column lname so that the last name is alphabetized (its sorted by the clustered index create)
CREATE CLUSTERED INDEX [Idx_Phonebook_Lname]
ON Phonebook(lname ASC)
GO

-- View the records. This time notice that the last name is in order
SELECT * FROM Phonebook

INSERT INTO Phonebook VALUES (1003, 'Briggham', 'John', '777-555-1212')
SELECT * FROM Phonebook