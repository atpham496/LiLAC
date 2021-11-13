drop database if exists LiLac;
create database LiLac;
use LiLac;

-- dropping existing triggers
drop trigger if exists AddFlowerBouquet;
drop trigger if exists AddFlowerInventory;

-- dropping schemas if exists
drop table if exists Sale;
drop table if exists Customer;
drop table if exists Florist;
drop table if exists Bouquet;
drop table if exists Flower;

/* Creating the schema for tables */
CREATE TABLE Flower (
fName VARCHAR(50) NOT NULL UNIQUE,
color VARCHAR(25),
fPrice INT,
fID INT,
PRIMARY KEY(fID)
);


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


CREATE TABLE Florist (
fID INT,
numFlower INT,
restockDate DATE,
FOREIGN KEY (fID) REFERENCES Flower(fID)
);

CREATE TABLE Customer (
cName VARCHAR(50) NOT NULL UNIQUE,
cID INT,
primary key(cID)
);

create table Sale
(cID int,
bID int,
pricePaid real default null,
packaging VARCHAR(50),
FOREIGN KEY (bID) REFERENCES Bouquet (bID),
FOREIGN KEY (cID) REFERENCES Customer (cID)
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

INSERT INTO Customer VALUES('Gracie Chung', 201);
INSERT INTO Customer VALUES('Alex Harris', 202);
INSERT INTO Customer VALUES('Sungchan Jung', 203);
INSERT INTO Customer VALUES('Erin Mac', 204);
INSERT INTO Customer VALUES('Hayden Edwards', 205);
INSERT INTO Customer VALUES('Sen Fall', 206);
INSERT INTO Customer VALUES('Jisung Park', 207);

INSERT INTO Sale VALUES(204, 2, 30, 'vase');
INSERT INTO Sale VALUES(204, 1, 15, 'vase');
INSERT INTO Sale VALUES(206, 5, 20, 'to go');
INSERT INTO Sale VALUES(207, 4, 12, 'vase');
INSERT INTO Sale VALUES(203, 3, 30, 'vase');
INSERT INTO Sale VALUES(201, 1, 15, 'vase');
INSERT INTO Sale VALUES(201, 1, 15, 'vase');


/* Triggers for Database */

/* Trigger: whenever a new type of flower is added, florist buys 50 of them */
/* Trigger: whenever a new type of flower is added, florist buys 50 of them */
delimiter //
create trigger AddFlowerInventory 
after insert on Flower
for each row

begin
	IF (new.fID not in (select fID from florist))
    THEN
		insert into Florist values (new.fID, 50, CURDATE());
	END IF;
end; //

/* Trigger: whenever a new type of flower is added, florist creates a bouquet of that new flower.
The price of this new bouquet is 5 multiplied by the price of each flower. 
The name of this new bouquet is "name of flower" + "Bouquet"
The number of this bouquet is defaulted to 5. 
The amount of flowers in the bouquet is defaulted to 5. 
The bID of this new bouquet is 1 + highest bID
*/

delimiter //
create trigger AddFlowerBouquet
after insert on Flower
for each row
begin
    IF new.fID not in (select fID from Bouquet) 
    THEN
        insert into Bouquet values (5 * new.fPrice, CONCAT(new.fname, ' Bouquet') , 5, 5, new.fID, 1+(select max(bID) as bID from bouquet as b2));
    end if;
end; //

delimiter ;

select * from Flower;
select * from Bouquet;
select * from Florist;
select * from Customer
order by cID ASC;
select * from Sale;

-- a potential relation for the User to see
select Customer.cName, Bouquet.bName, Sale.cID, Sale.bID, Sale.pricePaid, Sale.packaging
from Sale, Customer, Bouquet
where Sale.cID = Customer.cID AND Sale.bID = Bouquet.bID;

-- relation to determine the total price of a bouquet
select Flower.fID, Bouquet.bID, Flower.fPrice, Bouquet.fCount, Flower.fPrice * Bouquet.fCount as totalPrice
from Flower, Bouquet
where Flower.fID = Bouquet.fID;