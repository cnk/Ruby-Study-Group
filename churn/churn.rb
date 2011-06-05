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

  def date(a_time)
    a_time.strftime("%Y-%m-%d")
  end

  def change_count_for(name, start_date)
    extract_change_count_from(log(name, start_date))
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
  attr_reader :start_date

  # On instantiation, set up an instance variable to hold subsystem lines
  def initialize
    @subsystem_lines = []
  end

  def use_date(start_date)
    @start_date = start_date
  end

  def use_subsystem_with_change_count(name, count)
    @subsystem_lines << subsystem_line(name, count)
  end

  def header(start_date)
    #  "Changes since " + d.strftime("%Y-%m-%d")+":"
    #  "Changes since #{d.strftime("%Y-%m-%d")}:"
    #  d.strftime("Changes since %Y-%m-%d:")'
    "Changes since #{start_date}:"
  end

  def asterisks_for(n)
    '*'.*((n/5.0).round)   #return n/5 asterisks, rounded up or down
  end

  def subsystem_line(name, count)
    "#{name.rjust(14)} #{asterisks_for(count)} (#{count})"
  end

  # return the number in the parentheses from this string: "       ui2 **** (19)"
  def churn_line_to_int(line)
    /\((\d+)\)/.match(line)[1].to_i
    # line =~ /\((\d+)\)/
    # $1.to_i
  end

  def order_by_descending_change_count(lines)
    lines.sort do |line_a, line_b|
      line_a_count = churn_line_to_int(line_a)
      line_b_count = churn_line_to_int(line_b)
      - (line_a_count <=> line_b_count)
    end
  end

  def output
    puts header(@start_date)
    puts order_by_descending_change_count(@subsystem_lines)
  end
end

def month_before(t)
  t - (28*60*60*24)
end

if $0 == __FILE__   
  subsystem_names = ['audit', 'fulfillment', 'persistence', 'ui', 'util', 'inventory']
  root="svn://rubyforge.org//var/svn/churn-demo"
  repository = SubversionRepository.new(root)
  start_date = repository.date(month_before(Time.now))

  formatter = Formatter.new
  formatter.use_date(start_date)
  subsystem_names.each do | name |
    formatter.use_subsystem_with_change_count(name, repository.change_count_for(name, start_date))
  end
  puts formatter.output
end
