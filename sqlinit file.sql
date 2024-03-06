create table user (
    Email VARCHAR(255) PRIMARY KEY,
    fullName VARCHAR(255),
    password VARCHAR(255)
);
INSERT INTO user (Email, fullName, password) VALUES ('john.doe@example.com', 'John Doe', 'password123');
INSERT INTO user (Email, fullName, password) VALUES ('jane.smith@example.com', 'Jane Smith', 'password456');
INSERT INTO user (Email, fullName, password) VALUES ('michael.brown@example.com', 'Michael Brown', 'password789');
INSERT INTO user (Email, fullName, password) VALUES ('lisa.white@example.com', 'Lisa White', 'password101');
INSERT INTO user (Email, fullName, password) VALUES ('david.johnson@example.com', 'David Johnson', 'password102');

select * from user;


create table bookload(
id int not null AUTO_INCREMENT,
authorname varchar(255) not null,
bookname varchar(255) not null,
stock int
)