CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'Password123!';

GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'localhost' WITH GRANT OPTION;

CREATE USER 'app_user'@'%' IDENTIFIED BY 'Password123!';

GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'%' WITH GRANT OPTION;