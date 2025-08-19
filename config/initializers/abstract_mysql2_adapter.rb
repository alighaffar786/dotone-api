# Monkey Patch for MySQL 5.7
# Problem: MySQL 5.7 will complain that Primary key can't be null
# when using the default Rails migration
# Source: https://stackoverflow.com/questions/33742967/primary-key-issue-with-creating-tables-in-rails-using-rake-dbmigrate-command-wi/34555109#34555109

class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  NATIVE_DATABASE_TYPES[:primary_key] = 'int(11) auto_increment PRIMARY KEY'
end
