require 'test_helper'

class ParsingQuirksTest < Test::Unit::TestCase
  include Liquid

  def test_parsing_css
    text = " div { font-weight: bold; } "
    assert_equal text, Template.parse(text).render!
  end

  def test_raise_on_single_close_bracet
    assert_raise(SyntaxError) do
      Template.parse("text {{method} oh nos!")
    end
  end

  def test_raise_on_label_and_no_close_bracets
    assert_raise(SyntaxError) do
      Template.parse("TEST {{ ")
    end
  end

  def test_raise_on_label_and_no_close_bracets_percent
    assert_raise(SyntaxError) do
      Template.parse("TEST {% ")
    end
  end

  def test_error_on_empty_filter
    assert_nothing_raised do
      Template.parse("{{test}}")
      Template.parse("{{|test}}")
    end
    with_error_mode(:strict) do
      assert_raise(SyntaxError) do
        Template.parse("{{test |a|b|}}")
      end
    end
  end

  def test_meaningless_parens_error
    with_error_mode(:strict) do
      assert_raise(SyntaxError) do
        markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_unexpected_characters_syntax_error
    with_error_mode(:strict) do
      assert_raise(SyntaxError) do
        markup = "true && false"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
      assert_raise(SyntaxError) do
        markup = "false || true"
        Template.parse("{% if #{markup} %} YES {% endif %}")
      end
    end
  end

  def test_no_error_on_lax_empty_filter
    assert_nothing_raised do
      Template.parse("{{test |a|b|}}", :error_mode => :lax)
      Template.parse("{{test}}", :error_mode => :lax)
      Template.parse("{{|test|}}", :error_mode => :lax)
    end
  end

  def test_meaningless_parens_lax
    with_error_mode(:lax) do
      assigns = {'b' => 'bar', 'c' => 'baz'}
      markup = "a == 'foo' or (b == 'bar' and c == 'baz') or false"
      assert_template_result(' YES ',"{% if #{markup} %} YES {% endif %}", assigns)
    end
  end

  def test_unexpected_characters_silently_eat_logic_lax
    with_error_mode(:lax) do
      markup = "true && false"
      assert_template_result(' YES ',"{% if #{markup} %} YES {% endif %}")
      markup = "false || true"
      assert_template_result('',"{% if #{markup} %} YES {% endif %}")
    end
  end

  def test_error_on_variables_containing_curly_bracket
    assert_nothing_raised do
      Template.parse("{{ '{test}' }}")
    end
  end

  def test_variables_containing_single_curly_bracket
    text = '{test}'

    template = ''
    assert_nothing_raised do
      template = Template.parse("{{ '#{text}' }}")
    end

    assert_equal text, template.render
  end

  def test_variables_containing_double_curly_bracket
    text = "{\"foo\":{\"bar\":\"rab\"}}"
    template = ''
    assert_nothing_raised do
      template = Template.parse("{{ '#{text}' }}")
    end

    assert_equal text, template.render

    text = "{{fancy{{\\'user\\'}}name}}"
    template = ''
    assert_nothing_raised do
      template = Template.parse("{{ '#{text}' | remove:'{{just{{CurlyBrackets}}Again}}' }}", error_mode: :lax)
    end

    assert_equal text, template.render
  end

  def test_variables_with_escaped_quotes
    text = 'test \" escaping'
    template = Template.parse("{{ \"#{text}\" }}", error_mode: :lax)

    assert_equal text, template.render

    text = 'test \\\' escaping'
    template = Template.parse("{{ '#{text}' }}", error_mode: :lax)

    assert_equal text, template.render
  end

end # ParsingQuirksTest
