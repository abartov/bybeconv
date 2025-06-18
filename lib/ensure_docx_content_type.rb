# frozen_string_literal: true

# Method to set proper content-type for *.docx file attachments
module EnsureDocxContentType
  module InstanceMethods
    #
    # If the #attachment is set, and the content type is application/zip, but has
    # a .docx extension, change the #attachment_content_type field.
    #
    def set_proper_docx_content_type_for_attachment
      return unless doc?
      return unless doc_content_type == 'application/zip'
      return unless doc_file_name =~ /\.docx\z/

      attachment_content_type = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    end
  end

  def self.included(base)
    base.include InstanceMethods
    # This should be a before_validation callback on the Model, because if Paperclip's
    # validator hits this before this can run, its point is moot.
    base.before_validation :set_proper_docx_content_type_for_attachment
  end
end
