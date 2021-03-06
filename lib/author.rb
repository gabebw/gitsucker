require 'nokogiri'

class Author
  attr_reader :score

  def initialize(name)
    @name = name
    @score = user_score
  end

  def stats
    [
      @name,
      public_repo_count,
      original_repo_count,
      forked_repo_count,
      ruby_repo_count,
      js_repo_count,
      @score
    ]
  end

  def self.stat_types
    %w(name all originals forked ruby js score)
  end

  private

  def forked_repo_count
    @forked ||= public_repo_count - original_repo_count
  end

  def github_profile
    @github_profile ||= Nokogiri::HTML(open('https://github.com/' + @name))
  end

  def js_repo_count
    @js ||= github_profile.css('ul.repo-stats').select{|li| li.text =~ /JavaScript/}.count
  end

  def original_repo_count
    @original ||= github_profile.css('.source').count
  end

  def public_repo_count
    @public_count ||= github_profile.css('.public').count
  end

  def ruby_repo_count
    @ruby ||= github_profile.css('ul.repo-stats').select{|li| li.text =~ /Ruby/}.count
  end

  def user_score
    score = original_repo_count * ORIGINAL_REPO_VALUE
    score += ruby_repo_count * RUBY_REPO_VALUE
    score += js_repo_count * JS_REPO_VALUE
    score += forked_repo_count * FORKED_REPO_VALUE
  end
end
