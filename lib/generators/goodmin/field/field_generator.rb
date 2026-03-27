require "goodmin/generators/named_base"

class Goodmin::FieldGenerator < Goodmin::Generators::NamedBase
  def create_field
    template "field.rb", File.join("app/goodmin/fields", class_path, "#{file_name}_field.rb")
  end

  def create_views
    template "field_form.html.erb", File.join("app/views/goodmin/fields", file_name, "_form.html.erb")
    template "field_index.html.erb", File.join("app/views/goodmin/fields", file_name, "_index.html.erb")
    template "field_show.html.erb", File.join("app/views/goodmin/fields", file_name, "_show.html.erb")
  end

  private

  def class_name
    @_class_name ||= name.camelize
  end

  def file_name
    @_file_name ||= name.demodulize.underscore
  end
end
