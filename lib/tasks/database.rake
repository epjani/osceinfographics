namespace :db do
  
  desc "Drop all sequences and tables (only works for localhost connections)."
  task :drop_db => :environment do
    
    puts "Deleting tables ..."
    ActiveRecord::Base.connection.tables.each do |table_name| 
      printf "  %-30s", table_name  
      ActiveRecord::Base.connection.drop_table(table_name) 
      puts "[deleted]"
    end
    
    puts "Deleting sequences ..."
    sequences = ActiveRecord::Base.connection.select_rows("SELECT s.relname as sequence_name FROM pg_class s JOIN pg_depend d ON d.objid = s.oid LEFT JOIN pg_class t ON d.refobjid = t.oid  LEFT JOIN pg_attribute a ON (d.refobjid, d.refobjsubid) = (a.attrelid, a.attnum) WHERE s.relkind = 'S'")
    sequences.each do |seq_row|
      seq_name = seq_row[0]
      printf "  %-30s", seq_name  
      ActiveRecord::Base.connection.execute("DROP SEQUENCE #{seq_name}")
      puts "[deleted]"
    end
    
    puts "Done."
  end
end