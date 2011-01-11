class String
  def remove_require_lines
    self.split("\n").reject{|line| line.start_with? 'require' }.join("\n")
  end
  def preify
    self.gsub('<','&lt;').gsub('>','&gt;').gsub("\n","<br/>").gsub("\s","&nbsp;")
  end
  def swap_user_values(input_values)
    count = 0
    method_area = false
    method_name = nil
    method_indentation = 0
    in_ruby_v = nil
    in_ruby_indentation = 0
    in_correct_ruby_v = true

    self.split("\n").map do |line|
      if match = line.match(/^(\s{2}*)in_ruby_version.*[\"\'](.*)[\"\']/)
        in_ruby_indentation = match[1].size
        in_ruby_v = match[2]
        in_correct_ruby_v = in_ruby_v.include? "1.8"
        next
      elsif in_ruby_v
        if line.match(/^\s{#{in_ruby_indentation}}end/) 
          in_ruby_v = nil
          in_ruby_indentation = 0
          in_correct_ruby_v = true
          next
        else
          line = line[in_ruby_indentation..-1].to_s
        end
      end
      next unless in_correct_ruby_v
      if match = line.match(/^(\s{2}*)def test_/)
        method_area = true
        method_indentation = match[1].size
        method_name = (methodx = line.match(/test_\S*/)) && methodx[0]
      elsif line.start_with?(/\s{#{method_indentation}}end/) && method_area
        method_area = false
        method_name = nil
      end

      if line.strip.start_with? "#"
        line
      else
        line.gsub(/__/) do |match|
          if %w{test_assert_truth test_assert_with_message}.include?(method_name) &&
              (input_values[count].nil? || input_values[count].empty?)
            input_values[count] = 'false'
          end
          x = input_values[count].to_s == "" ? "__" : "#{input_values[count]}"
          count = count + 1
          x
        end
      end
    end.compact.join("\n")
  end
  def swap_input_fields(input_values, passes, failures)
    count        = 0
    method_count = 0
    method_area  = false
    method_name = nil
    method_indentation = 0
    in_ruby_v = nil
    in_ruby_indentation = 0
    in_correct_ruby_v = true

    self.split("\n").map do |line|
      true_line = line.gsub('&nbsp;',' ')
      if match = true_line.match(/^(\s{2}*)in_ruby_version.*[\"\'](.*)[\"\']/)
        in_ruby_indentation = match[1].size
        in_ruby_v = match[2]
        in_correct_ruby_v = in_ruby_v.include? "1.8" 
        next
      elsif in_ruby_v
        if true_line.match(/^\s{#{in_ruby_indentation}}end/) 
          in_ruby_v = nil
          in_ruby_indentation = 0
          in_correct_ruby_v = true
          next
        else
          line = line[(in_ruby_indentation*('&nbsp;'.size))..-1].to_s
          true_line = line.gsub('&nbsp;',' ')
        end
      end
      next unless in_correct_ruby_v
      if match = true_line.match(/^(\s{2}*)def test_/)
        method_area = true
        method_indentation = match[1].size
        method_count = method_count + 1
        method_name = (methodx = true_line.match(/test_\S*/)) && methodx[0]
        failure = failures[method_name.to_sym]
        "#{fail_message(failure)}
        <div nowrap='nowrap' style='background-color:#{failure ? 'red' : 'green'}'>
        #{line}"
      elsif method_area && true_line.match(/^\s{#{method_indentation}}end/)
        method_area = false
        "#{line}</div>"
      elsif line.gsub("&nbsp;","").start_with?("#")
        line
      else
        line.gsub(/__/) do |match|
          if %w{test_assert_truth test_assert_with_message}.include?(method_name) &&
              (input_values[count].nil? || input_values[count].empty?)
            x = 'false'
          else
            x = input_values[count].to_s.gsub("'", "&apos;")
          end
          
          count = count + 1
          "<input type='text' name='input[]' value='#{x}\' />"
        end
      end
    end.compact.join('<br/>')
  end
  def fail_message(failure)
    return nil if failure.nil?
    if failure.message.include? "FILL ME IN"
      "  Please meditate on the following.".preify
    elsif failure.message.include? "undefined local"
      failure.message.split("for #<").first.preify  
    else
      "  The answers which you seek:\n  #{failure.message.gsub("\n"," ")}".preify
    end
  end
end
