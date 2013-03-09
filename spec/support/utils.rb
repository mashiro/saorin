require 'saorin/test'

def deserialize(data)
  data && JSON.load(data)
end

def validates(process, inputs, answers)
  inputs.zip(answers).each do |input, answer|
    output = deserialize process.call(input)
    answer = deserialize answer
    output.should eq answer
  end
end
