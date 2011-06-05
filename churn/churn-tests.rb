#---
# Excerpted from "Everyday Scripting in Ruby"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/bmsft for more book information.
#---
require 'test/unit' 
require 'churn'     

# If I grouped the methods under test, it seems sensible to also group
# the methods testing them, so I put them all inside their own test
# class.

class SubversionRepositoryTests < Test::Unit::TestCase

  # Each one of the repository test methods needs a repository. Each
  # one would create it exactly the same way. I can remove that
  # duplication by putting it in this setup method. Like methods
  # beginning with "test", it's special. Test::Unit knows to run it
  # before each test method.
  #
  # Since SubversionRepositoryTests is a class like any other, I can
  # use an instance variable to communicate the repository to the test
  # methods.

  def setup
    @repository = SubversionRepository.new('root')
  end

  def test_date
    assert_equal('2005-03-04',
                 @repository.date(Time.local(2005, 3, 4)))
  end

  def test_subversion_log_can_have_no_changes
    assert_equal(0, @repository.extract_change_count_from("------------------------------------------------------------------------\n"))
  end
  
  def test_subversion_log_with_changes
    assert_equal(2, @repository.extract_change_count_from("------------------------------------------------------------------------\nr2531 | bem | 2005-07-01 01:11:44 -0500 (Fri, 01 Jul 2005) | 1 line\n\nrevisions up through ch 3 exercises\n------------------------------------------------------------------------\nr2524 | bem | 2005-06-30 18:45:59 -0500 (Thu, 30 Jun 2005) | 1 line\n\nresults of read-through; including renaming mistyping to snapshots\n------------------------------------------------------------------------\n"))
  end

end

class FormatterTests < Test::Unit::TestCase

  def setup
    @formatter = Formatter.new
  end

  def test_use_date_creates_start_date
    assert_nil @formatter.start_date
    @formatter.use_date("2005-08-05")
    assert_not_nil @formatter.start_date
  end

  def test_header_format
    assert_equal("Changes since 2005-08-05:",
                 @formatter.header('2005-08-05'))
  end

  def test_normal_subsystem_line_format
    assert_equal('         audit ********* (45)',
                 @formatter.subsystem_line("audit", 45))
  end

  def test_asterisks_for_divides_by_five
    assert_equal('****', @formatter.asterisks_for(20))
  end

  def test_asterisks_for_rounds_up_and_down
    assert_equal('****', @formatter.asterisks_for(18))
    assert_equal('***', @formatter.asterisks_for(17))
  end

  # CNK I refactored to do the ordering before creating the line, so I don't need this anymore
  # def test_churn_line_to_int_extracts_parenthesized_change_count
  #   assert_equal(19, @formatter.churn_line_to_int("       ui2 **** (19)"))
  #   assert_equal(9, @formatter.churn_line_to_int("       ui ** (9)"))
  # end

  def test_order_by_descending_change_count
    original = [['audit', 5], ['ui', 39], ['util', 0]]
    expected = [['ui', 39], ['audit', 5], ['util', 0]]
    actual = @formatter.order_by_descending_change_count(original)

    assert_equal(expected, actual)
  end

  def test_use_subsystem_with_change_count_collects_subsystem_lines
    change_data = [['audit', 5], ['ui', 39], ['util', 0]]
    change_data.each do |name, change_count|
      @formatter.use_subsystem_with_change_count(name, change_count)
    end
    assert_equal change_data, @formatter.changes
  end

  # general outline based on original test_order_by_descending_change_count
  def test_output
    expected = ["Changes since 2011-05-08:", "     inventory *** (16)", "            ui ** (11)", "   fulfillment ** (10)"]
    # set up data
    start_date = "2011-05-08"
    changes = [['inventory', 16], ['ui', 11], ['fulfillment', 10]]

    # feed it to formatter as churn does
    @formatter.use_date(start_date)
    changes.each do |name, change_count|
      @formatter.use_subsystem_with_change_count(name, change_count)
    end
    
    assert_equal expected, @formatter.output
  end

end

class ChurnTests < Test::Unit::TestCase 

  def test_month_before_is_28_days
    assert_equal(Time.local(2005, 1, 1),
                 month_before(Time.local(2005, 1, 29)))
  end

end
