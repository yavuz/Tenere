CREATE TABLE newscat (
id integer PRIMARY KEY AUTOINCREMENT,
name varchar(255) NOT NULL,
slugname varchar(255) NOT NULL,
url char(255) NOT NULL
);


CREATE TABLE mynewscat (
id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
catid integer(5) NOT NULL
);

CREATE TABLE news (
id integer PRIMARY KEY AUTOINCREMENT NOT NULL,
title varchar(255) NOT NULL,
image varchar(255),
summary text,
date varchar(255),
url varchar(255),
catid integer
);

CREATE UNIQUE INDEX SameNews ON news (url DESC, title DESC);