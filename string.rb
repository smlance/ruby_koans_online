class String
  def remove_require_lines
    self.split("\n").reject{|line| line.start_with? 'require' }.join("\n")
  end
  def preify
    self.gsub("\n","<br/>").gsub("\s","&nbsp;")
  end
  def swap_input_fields(input_values, passes, failures)
    count        = 0
    method_count = 0
    method_area  = false

    self.split("\n").map do |line|
      if line.start_with? "&nbsp;&nbsp;def&nbsp;test_"
        method_count = method_count + 1
        "#{fail_message(failures, method_count - passes - 1)}
        <div style='background-color:#{method_count <= passes ? 'green' : 'red'}'>
        #{line}"
      elsif line.start_with? "&nbsp;&nbsp;end"
        "#{line}</div>"
      else
        line.gsub(/__/) do |match|
          x = input_values[count]
          count = count + 1
          "<input type='text' name='input[]' value='#{x}' />"
        end
      end
    end.join('<br/>')
  end
  def fail_message(failures, fail_index)
    fail_message = ''
    if fail_index >= 0
      fail_message = failures[fail_index] || ''
      if fail_message.include? "FILL ME IN"
        fail_message = "Please meditate on the following." 
      else
        fail_message = "The answers which you seek:<br/>#{fail_message}"
      end
    end
  end
end
