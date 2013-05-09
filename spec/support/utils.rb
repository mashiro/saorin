require 'saorin/test'

def json_decode(data)
  data && JSON.load(data)
end

def validates(process, inputs, answers)
  inputs.zip(answers).each do |input, answer|
    output = process.call(input)
    answer = json_decode answer
    output.should eq answer
  end
end
