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

DROP TABLE IF EXISTS Florist;
CREATE TABLE Florist (
fID INT,
numFlower INT,
restockDate DATE,
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

INSERT INTO Florist VALUES(1001, 30, '2021-11-11');
INSERT INTO Florist VALUES(1002, 53, '2021-11-5');
INSERT INTO Florist VALUES(1003, 46, '2021-10-25');
INSERT INTO Florist VALUES(1004, 25, '2021-10-22');
INSERT INTO Florist VALUES(1005, 15, '2021-11-8');

/* Triggers for Database */

/* Trigger: whenever a new type of flower is added, florist buys 50 of them */
create trigger AddFlowerInventory 
after insert on Flower
for each row
when new.fID not in (select fID from florist)
begin
	insert into Florist values (new.fID, 50, DATE('now'));
end;

/* Trigger: whenever a new type of flower is added, florist creates a bouquet of that new flower.
The price of this new bouquet is 5 multiplied by the price of each flower. 
The name of this new bouquet is "name of flower" + "Bouquet"
The number of this bouquet is defaulted to 5. 
The amount of flowers in the bouquet is defaulted to 5. 
The bID of this new bouquet is 1 + highest bID
*/
create trigger AddFlowerBouquet
after insert on Flower
for each row
when new.fID not in (select fID from Bouquet)
begin
	insert into Bouquet values (5 * new.fPrice, new.fName || ' Bouquet' , 5, 5, new.fID, 1+(select max (bID) from bouquet));
end;








