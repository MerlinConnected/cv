module Jekyll
  module WorkExperienceFilter
    def format_work_experience(content)
      # Split content by h2 headers to group sections
      sections = content.split(/(<h2[^>]*>.*?<\/h2>)/).reject(&:empty?)

      result = ""
      current_section_title = nil
      current_section_items = []

      sections.each do |section|
        if section.match(/<h2[^>]*>(.*?)<\/h2>/)
          # Process previous section if it exists
          if current_section_title && !current_section_items.empty?
            result += create_section_html(current_section_title, current_section_items)
          end

          # Start new section - replace h2 with standard class
          section_title = $1
          current_section_title = "<h2 class=\"section-title\">#{section_title}</h2>"
          current_section_items = []
        else
          # Process items in current section
          pattern = /<p><em>([^<]+)<\/em><\/p>\s*<h3[^>]*>([^<]+)<\/h3>\s*<p>([^<]+?)<\/p>(.*?)(?=<p><em>[^<]+<\/em><\/p>\s*<h3|$)/m

          section.gsub(pattern) do |match|
            date = $1
            title = $2
            location_and_description = $3
            additional_content = $4.strip

            lines = location_and_description.split(/\n|<br\s*\/?>/)
            location = lines.first.strip
            description_lines = lines[1..-1]&.reject(&:empty?)

            current_section_items << create_experience_html(date, title, location, description_lines, additional_content)
            "" # Remove the matched content since we're collecting it
          end
        end
      end

      # Process final section
      if current_section_title && !current_section_items.empty?
        result += create_section_html(current_section_title, current_section_items)
      end

      result
    end


    private


    def create_section_html(section_header, items)
      <<~HTML
        <section>
          #{section_header}
          #{items.join}
        </section>
      HTML
    end

    def create_experience_html(date, title, location, description_lines = nil, additional_content = "")
      html = <<~HTML
        <div class="item">
          <p>#{date}</p>
          <div class="item-details">
            <h3>#{title}</h3>
            <p class="item-sub">#{location}</p>
      HTML

      # Add description lines if they exist
      if description_lines && !description_lines.empty?
        description_text = description_lines.join('<br>')
        html += <<~HTML
            <p class="item-description">
              #{description_text}
            </p>
        HTML
      end

      html += <<~HTML
          </div>
        </div>
      HTML

      html.strip
    end
  end
end

Liquid::Template.register_filter(Jekyll::WorkExperienceFilter)
