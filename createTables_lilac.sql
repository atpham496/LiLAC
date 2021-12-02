drop database if exists LiLac;
create database LiLac;
use LiLac;

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
FOREIGN KEY (fID) REFERENCES Flower(fID) on delete cascade
);

DROP TABLE IF EXISTS Florist;
CREATE TABLE Florist (
fID INT,
numFlower INT,
restockDate DATE,
FOREIGN KEY (fID) REFERENCES Flower(fID) on delete cascade
);

DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer (
cID INT,
cName VARCHAR(50) NOT NULL UNIQUE,
discountUser BOOLEAN,
updatedAt DATE,
PRIMARY KEY(cID)
);

DROP TABLE IF EXISTS Sale;
CREATE TABLE Sale
(cID INT,
bID INT,
UNIQUE KEY(cID,bID),
pricePaid REAL DEFAULT NULL,
packaging VARCHAR(50),
FOREIGN KEY (bID) REFERENCES Bouquet (bID) on delete cascade,
FOREIGN KEY (cID) REFERENCES Customer (cID) on delete cascade
);

DROP TABLE IF EXISTS Archive;
CREATE TABLE CustomerArchive(
cIDArchive INT,
cNameArchive VARCHAR(50) NOT NULL UNIQUE,
discountUserArchive BOOLEAN,
updatedAtArchive DATE
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

INSERT INTO Customer VALUES(201, 'Gracie Chung', False, '2021-10-22');
INSERT INTO Customer VALUES(202, 'Alex Harris', False, '2021-10-22');
INSERT INTO Customer VALUES(203, 'Sungchan Jung', False, '2021-10-22' );
INSERT INTO Customer VALUES(204, 'Erin Mac', False, '2021-10-22');
INSERT INTO Customer VALUES(205, 'Hayden Edwards', False, '2021-10-22');
INSERT INTO Customer VALUES(206, 'Sen Fall', False, '2021-10-22');
INSERT INTO Customer VALUES(207, 'Jisung Park', False, '2021-10-22');
INSERT INTO Customer VALUES(200, 'Catherine K', False, '2020-11-26');

INSERT INTO Sale VALUES(204, 2, 30, 'vase');
INSERT INTO Sale VALUES(204, 1, 15, 'vase');
INSERT INTO Sale VALUES(206, 5, 20, 'to go');
INSERT INTO Sale VALUES(207, 4, 12, 'vase');
INSERT INTO Sale VALUES(203, 3, 30, 'vase');
INSERT INTO Sale VALUES(201, 1, 15, 'vase');

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

/* Trigger: whenever a new sale is made, check if the customer that made that purchase has a total purchase of  >= 50.
If that is true, they are now a discount user. */
delimiter //
create trigger UpdateDiscountUser
after insert on Sale
for each row
begin
    IF ( (select sum(Sale.pricePaid) from Customer inner join Sale using (cID) where cID = new.cID) >= 50 )
    THEN
		update Customer set discountUser = True where cID = new.cID;
    end if;
end; //


/* Stored procedure to get a customer's bouquet ID and bouquet type
Call example: 
mysql> call getCustomerBouquetByName('Erin Mac');
+--------------+
| bouquetName  |
+--------------+
| Lily Bouquet |
| Rose Bouquet |
+--------------+
*/
delimiter //
create procedure getCustomerBouquetByName(IN inputcName VARCHAR(50))
begin
	select Bouquet.bName as bouquetName
    from Customer
    inner join Sale using (cID)
    inner join Bouquet using (bID)
    where cName = inputcName;
end//
delimiter ;

/* Stored procedure to calculate a customer's total purchase 
Call example: 
mysql> call getTotalSpentByCustomerID(204, @totalSpent);
+-------------+
| @totalSpent |
+-------------+
|          45 |
+-------------+
*/
delimiter //
create procedure getTotalSpentByCustomerID(
IN inputcID INT,
OUT totalSpent INT)
begin
	select sum(Sale.pricePaid) as totalPrice
    into totalSpent
    from Customer
    inner join Sale using (cID)
    where cID = inputcID;
end//
delimiter ;

delimiter //
create procedure archiveCustomerProcedure(
IN inputDate DATE)
begin
	insert into CustomerArchive(cIDArchive, cNameArchive, discountUserArchive, updatedAtArchive)
    select cID, cName, discountUser, updatedAt
    from Customer
    where updatedAt < inputDate;
    
    delete from Customer where updatedAt < inputDate;
end//
delimiter ;

select * FROM Flower;

select * FROM Bouquet;

select * FROM Florist;

select * FROM Customer;

select * FROM Sale;

/* Functionality Number 1.
using left outer join to show customers that hasnt bought any bouquets
*/
select * FROM Customer Left Outer Join Sale on Customer.cID = Sale.cID 
where pricePaid is null;

/* Functionality Number 2
using group by and having to find customers who spent a total over $25
*/
select Customer.cName, sum(Sale.pricePaid) as cumulative_pricePaid 
from Sale, Customer, Bouquet 
where Sale.cID = Customer.cID AND Sale.bID = Bouquet.bID 
group by cName 
having sum(Sale.pricePaid) >= 25;

/* Functionality Number 3
Using union (math set operation), find all the flowers and bouquets the store has 
*/
SELECT fName FROM Flower UNION SELECT bName FROM Bouquet;

/* Functionality Number 4
Find a customer’s cID given their name.
for example, we use cName = 'Erin Mac' to replace cName = ? from jdbc
*/
Select cID From Customer Where cName = 'Erin Mac';

/* Functionality Number 5
Selecting Customer's name, the name of the bouquet, the total price paid and the type of packaging for each order a customer made  
(order history).
for example, we use Customer.cName = 'Jisung Park' to replace Customer.cName = ? in jdbc prepared statement
*/
Select Customer.cName, Customer.cID, Bouquet.bName, Sale.pricePaid, Sale.packaging 
From Customer, Sale, Bouquet 
Where Customer.cName = 'Jisung Park' and Customer.cID = Sale.cID and Sale.bID = Bouquet.bID;

/* Functionality Number 6
Select all the bouquet name, price, and stock
*/
select bName, bPrice, numLeft from Bouquet;

/* Functionality Number 7
Select all the bouquet name, price, and stock.
For example, we use bName = 'Rose Bouquet' to replace bName = ? from jdbc preparedstatement
*/
Select fName, color  
from Flower inner join Bouquet using (fID) 
where bName = 'Rose Bouquet';

/* Functionality Number 8
View when a flower is last restocked.
For example, we use bName = 'Rose Bouquet' to replace bName = ? from jdbc preparedstatement
*/
select restockDate 
from Florist inner join Flower using(fID) inner join Bouquet using (fID) 
where bName = 'Rose Bouquet';

/* Functionality 9
View the amount of flowers in a particular bouquet
For example, we use bName = 'Rose Bouquet' to replace bName = ? from jdbc preparedstatement
*/
select fCount from Bouquet where bName = 'Rose Bouquet';

/* Functionality 10
Insert a new customer to the Customer schema.
*/
insert into Customer values (208, 'New Customer', false, '2021-11-29');

/* Functionality 11
Selecting a bouquet given the name of the bouquet
For example, we use bName = 'Daisy Bouquet' to replace bName = ? from jdbc preparedstatement
*/
SELECT * FROM Bouquet WHERE bName = 'Daisy Bouquet';

/* Functionality 12
Retrieving the max fID from the Flower schema
*/
select max(fID) as fIDMAX from Flower;

/* Functionality 13
Inserting into Sale
*/
insert into Sale values (208, 4, 12, 'to go');
select * from Sale;

/* Functionality 14
Updating the bouquet count after the user makes a purchase
For example, we are updating numLeft of daisy bouquet with bID = 4.
*/
update bouquet as b1 inner join (select * from bouquet where bID = 4) as b2 using (bID) 
set b1.numLeft = b2.numLeft - 1 
where bID = 4;

select * from Bouquet;

/* Functionality 15
Given the customer’s cID and bID, show their name, bouquet they purchase, price paid, and packaging type 
(receipt)
For example, we use cID = 208 and bID = 4 to replace jdbc preparedStatement conditions cID = ? and bID = ?
*/
select cName, bName, pricePaid, packaging 
from sale inner join bouquet using (bID) inner join customer using (cID) 
where cID = 208 and bID = 4;

/* Functionality 16
Update packaging type.
For example, we use cID = 203 and bID = 3 to in place of jdbc preparedStatement conditions cID = ? and bID = ?
*/
select * from sale where cID = 203 and bId = 3;
update sale set packaging = 'to go' where cID = 203 and bId = 3;

select packaging from sale where cID = 203 and bId = 3;
