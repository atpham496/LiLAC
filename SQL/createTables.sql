/* Creating the schema for tables */
DROP TABLE IF EXISTS Flower;
CREATE TABLE Flower (
fName VARCHAR(50) NOT NULL UNIQUE,
color VARCHAR(25),
fPrice INT,
fID INT,
PRIMARY KEY(fID)
);


DROP TABLE IF EXISTS Bouquet;
CREATE TABLE Bouquet (
bPrice INT,
bName VARCHAR(50) NOT NULL UNIQUE,
numLeft INT,
fCount INT UNSIGNED,
fID INT,
bID INT,
PRIMARY KEY(bID),
FOREIGN KEY (fID) REFERENCES Flower(fID)
);


/* Populating tables with data */
INSERT INTO Flower VALUES("Rose", "red", 3, 1001);
INSERT INTO Flower VALUES("Lily", "pink", 3, 1002);
INSERT INTO Flower VALUES("Tulip", "yellow", 5, 1003);
INSERT INTO Flower VALUES("Daisy", "white", 2, 1004);
INSERT INTO Flower VALUES("Sunflower", "yellow", 5, 1005);
 
INSERT INTO Bouquet VALUES(15, "Rose Bouquet", 3, 5, 1001, 1);
INSERT INTO Bouquet VALUES(30, "Lily Bouquet", 1, 10, 1002, 2);
INSERT INTO Bouquet VALUES(30, "Tulip Bouquet", 5, 6, 1003, 3);
INSERT INTO Bouquet VALUES(12, "Daisy Bouquet", 9, 6, 1004, 4); 
INSERT INTO Bouquet VALUES(20, "Sunflower Bouquet", 0, 4, 1005, 5);
