#---
# Excerpted from "Everyday Scripting in Ruby"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmsft for more book information.
#---

# Verson from Chapter 11 - before the start of the exercises
# The corresponding test file runs without error: snapshots/churn-tests-classes.rb 

class SubversionRepository

  def initialize(root)
    @root = root    # (1)
  end

  def format_date(a_time)
    a_time.strftime("%Y-%m-%d")
  end

  def change_count_for(name, start_date)
    extract_change_count_from(log(name, format_date(start_date)))
  end

  def extract_change_count_from(log_text)
    lines = log_text.split("\n")
    dashed_lines = lines.find_all do | line |
      line.include?('--------') 
    end
    dashed_lines.length - 1     
  end

  def log(subsystem, start_date)
    # timespan = "--revision 'HEAD:{#{start_date}}'"
    # `svn log #{timespan} #{@root}/#{subsystem}`    
    
    # Our version with mocks because the svn repository is no longer available
    File.open("svn_logs/subversion-output-#{subsystem}.txt").read
  end
  
end

class Formatter
  # CNK what do people think about exposing these? I did it so I could
  # access their values in my tests. I think that is a code smell. How
  # should I be writing my unit tests so I am not testing the values
  # of internal data?
  attr_reader :start_date, :end_date, :changes

  # On instantiation, set up an instance variable to hold subsystem lines
  def initialize
    @changes = []
  end

  # This is now getting Time objects instead of strings
  def report_range(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def use_subsystem_with_change_count(name, count)
    @changes << [name, count]
  end

  def header(start_date)
    start_date.strftime("Changes since %Y-%m-%d:")
  end

  def asterisks_for(n)
    '*'.*((n/5.0).round)   #return n/5 asterisks, rounded up or down
  end

  def subsystem_line(name, count)
    "#{name.rjust(14)} #{asterisks_for(count)} (#{count})"
  end

  # changes is an array of arrays of the format [name, count]
  # So we want to sort by the second element - descending
  def order_by_descending_change_count(changes)
    changes.sort do |a, b|
      - (a[1] <=> b[1])
    end
  end

  def output
    output = []
    output << header(@start_date)
    ordered_changes = order_by_descending_change_count(@changes)
    ordered_changes.each do |change|
      output << subsystem_line(change[0], change[1])
    end
    output
  end
end

def month_before(t)
  t - (28*60*60*24)
end

if $0 == __FILE__   
  subsystem_names = ['audit', 'fulfillment', 'persistence', 'ui', 'util', 'inventory']
  root="svn://rubyforge.org//var/svn/churn-demo"
  repository = SubversionRepository.new(root)
  last_month = month_before(Time.now)

  formatter = Formatter.new
  formatter.report_range(last_month, Time.now)
  subsystem_names.each do | name |
    formatter.use_subsystem_with_change_count(name, repository.change_count_for(name, last_month))
  end
  puts formatter.output
end
