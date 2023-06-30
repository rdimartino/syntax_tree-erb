# frozen_string_literal: true

require "test_helper"

module SyntaxTree
  class HtmlTest < Minitest::Test
    def test_html_missing_end_tag
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<h1>Hello World")
      end
    end

    def test_html_incorrect_end_tag
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<h1>Hello World</h2>")
      end
    end

    def test_html_unmatched_double_quote
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<div class=\"card-\"\">Hello World</div>")
      end
    end

    def test_html_unmatched_single_quote
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<div class='card-''>Hello World</div>")
      end
    end

    def test_html_doctype
      parsed = ERB.parse("<!DOCTYPE html>")
      assert_instance_of(SyntaxTree::ERB::Doctype, parsed.elements.first)

      parsed = ERB.parse("<!doctype html>")
      assert_instance_of(SyntaxTree::ERB::Doctype, parsed.elements.first)
    end

    def test_html_comment
      source = "<!-- This is a HTML-comment -->\n"
      parsed = ERB.parse(source)
      elements = parsed.elements
      assert_equal(1, elements.size)
      assert_instance_of(SyntaxTree::ERB::HtmlComment, elements.first)

      formatted = ERB.format(source)
      assert_equal(source, formatted)
    end

    def test_html_within_quotes
      source =
        "<p>This is our text \"<strong><%= @object.quote %></strong>\"</p>"
      parsed = ERB.parse(source)
      elements = parsed.elements

      assert_equal(1, elements.size)
      assert_instance_of(SyntaxTree::ERB::HtmlNode, elements.first)
      elements = elements.first.elements

      assert_equal("This is our text \"", elements.first.value.value)
      assert_equal("\"", elements.last.value.value)
    end

    def test_html_tag_names
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<@br />")
      end
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<:br />")
      end
      assert_raises(SyntaxTree::ERB::Parser::ParseError) do
        ERB.parse("<#br />")
      end
    end

    def test_html_attribute_without_quotes
      source = "<div class=card>Hello World</div>"
      parsed = ERB.parse(source)
      elements = parsed.elements

      assert_equal(1, elements.size)
      assert_instance_of(SyntaxTree::ERB::HtmlNode, elements.first)
      assert_equal(1, elements.first.opening.attributes.size)

      attribute = elements.first.opening.attributes.first
      assert_equal("class", attribute.key.value)
      assert_equal("card", attribute.value.contents.first.value)

      formatted = ERB.format(source)
      assert_equal("<div class=\"card\">\n  Hello World\n</div>\n", formatted)
    end

    def test_html_attribute_without_content
      source = "<component-without-content>\n</component-without-content>\n"
      expected = "<component-without-content></component-without-content>\n"

      formatted = ERB.format(source)
      assert_equal(expected, formatted)
    end
  end
end
