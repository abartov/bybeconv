# frozen_string_literal: true

# This class represents single text inside an Ingestible.
# Each ingestible contains array of buffers serialized to json field works_buffer
class IngestibleText
  include ActiveModel::Model

  attr_accessor :content, :title

  def initialize(json)
    @title = json['title']
    @content = json['content']
  end

  def to_hash
    {
      title: @title,
      content: @content
    }
  end
end
