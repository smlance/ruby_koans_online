class String
  def remove_require_lines
    self.split("\n").reject{|line| line.start_with? 'require' }.join("\n")
  end
  def preify
    self.gsub('<','&lt;').gsub('>','&gt;').gsub("\n","<br/>").gsub("\s","&nbsp;")
  end
  def swap_user_values(input_values)
    count = 0
    self.split("\n").map do |line|
      if line.strip.start_with? "#"
        line
      else
        line.gsub(/__/) do |match|
          x = input_values[count].to_s == "" ? "__" : "#{input_values[count]}"
          count = count + 1
          x
        end
      end
    end.join("\n")
  end
  def swap_input_fields(input_values, passes, failures)
    count        = 0
    method_count = 0
    method_area  = false

    self.split("\n").map do |line|
      if line.start_with? "&nbsp;&nbsp;def&nbsp;test_"
        method_area = true
        method_count = method_count + 1
        method_name = (methodx = line.match(/test_\S*/)) && methodx[0]
# fail_message(failures, method_count - passes - 1)
        failure = failures[method_name.to_sym]
        "#{fail_message(failure)}
        <div nowrap='nowrap' style='background-color:#{failure ? 'red' : 'green'}'>
        #{line}"
      elsif line.start_with?("&nbsp;&nbsp;end") && method_area
        method_area = false
        "#{line}</div>"
      elsif line.gsub("&nbsp;","").start_with?("#")
        line
      else
        line.gsub(/__/) do |match|
          x = input_values[count].to_s.gsub("'", "&apos;")
          count = count + 1
          "<input type='text' name='input[]' value='#{x}\' />"
        end
      end
    end.join('<br/>')
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
