DROP SCHEMA IF EXISTS closets cascade;
CREATE SCHEMA closets;
SET search_path TO closets, public;

create domain percentage as integer
    default null
    check (value>=0 and value <=100);

-- Customers order products from the company.
-- We store their name, billing address, year-to-date
-- purchase total, credit limit, outstanding balance,
-- and negotiated discount percentage.
CREATE TABLE Customer (
    customerId integer PRIMARY KEY,
    name varchar(40) NOT NULL,
    street varchar(40) NOT NULL,
    city varchar(40) NOT NULL,
    province varchar(40) NOT NULL,
    ytdPurchaseTotal float NOT NULL default 0,
    creditLimit float NOT NULL,
    outstandingBalance float NOT NULL,
    discountPercentage percentage NOT NULL default 0
) ;

-- Each operation is performed in a specific workcenter.
-- We store their name and capacity.
CREATE TABLE Workcenter (
    name varchar(15) PRIMARY KEY,
    capacity integer NOT NULL
) ;


CREATE TABLE Product (
    productId integer PRIMARY KEY,
    productDesc varchar(25) NOT NULL,
    unitPrice float NOT NULL,
    quantity integer NOT NULL,
    lotSize integer NOT NULL,
    reorderPoint integer NOT NULL,
    numOrders integer NOT NULL
) ;

-- A tuple in Order represents the order for a 
-- specific product in that order. Orders can be
-- found by querying for the orderId.
CREATE TABLE Order (
    orderId integer NOT NULL,
    quantity integer NOT NULL,
    customerID integer REFERENCES Customer,
    productID integer REFERENCES Product,
    PRIMARY KEY (orderId, productID)
) ;

CREATE TABLE ProductionOrder (
    jobID integer NOT NULL,
    productID integer REFERENCES Product,
    quantity integer NOT NULL,
    estCompletionDate date NOT NULL,
    workcenter varchar(15) REFERENCES Workcenter
) ;

-- Routing holds routing information for all products. 
-- Routing for a given product can be found by querying the productId.
CREATE TABLE Routing (
    productId integer REFERENCES Product,
    opNo integer NOT NULL,
    opDesc varchar(25) NOT NULL,
    setupTime float NOT NULL,
    stdOpTime float NOT NULL,
    workcenter varchar(10) REFERENCES Workcenter,
    PRIMARY KEY (productID, opNo)
) ;

-- Parts are used in the assembly of products and may
-- require their own assembly as well.
-- We store their id, description, location, and code.
CREATE TABLE Part (
    partId integer PRIMARY KEY,
    partDesc varchar(25) NOT NULL,
    location varchar(1) NOT NULL,
    code integer NOT NULL
) ;

CREATE TABLE Invoice (
    invoiceId integer NOT NULL,
    customerId integer REFERENCES Customer,
    orderId integer REFERS Order,
    date date NOT NULL,
    totalAmount float NOT NULL,
    PRIMARY KEY(invoiceID, orderID)
) ;

-- Bill of Materials (BoM) can be generated by querying the following
-- two tables for a specified master/masterPart. The first table holds
-- BoMs for every product and the second holds BoMs for any part that
-- requires assembly before being used in a product's assembly.
CREATE TABLE ProductComposition (
    quantity integer NOT NULL
    master integer REFERENCES Product NOT NULL,
    sub integer REFERENCES Part NOT NULL,
    PRIMARY KEY (master, sub)
) ;

CREATE TABLE PartComposition (
    masterPart integer REFERENCES Part NOT NULL,
    subPart integer REFERENCES Part NOT NULL,
    PRIMARY KEY (masterPart, subPart)
) ;
