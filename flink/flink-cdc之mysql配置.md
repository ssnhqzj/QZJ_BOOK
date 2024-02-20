```sql
CREATE USER 'cdc'@'%' IDENTIFIED BY '123456';

GRANT SELECT, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%' ;

GRANT SELECT, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'cdc'@'%' ;

select host,user,authentication_string from user;

FLUSH PRIVILEGES;

drop USER 'cdc'@'localhost'
```