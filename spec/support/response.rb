require 'support/utils'

shared_examples 'rpc call with positional parameters' do
  it 'rpc call with positional parameters' do
    inputs  << %({"jsonrpc": "2.0", "method": "subtract1", "params": [42, 23], "id": 1})
    answers << %({"jsonrpc": "2.0", "result": 19, "id": 1})
    inputs  << %({"jsonrpc": "2.0", "method": "subtract1", "params": [23, 42], "id": 2})
    answers << %({"jsonrpc": "2.0", "result": -19, "id": 2})
    validates process, inputs, answers
  end
end

shared_examples 'rpc call with named parameters' do
  it 'rpc call with named parameters' do
    inputs  << %({"jsonrpc": "2.0", "method": "subtract2", "params": {"subtrahend": 23, "minuend": 42}, "id": 3})
    answers << %({"jsonrpc": "2.0", "result": 19, "id": 3})
    inputs  << %({"jsonrpc": "2.0", "method": "subtract2", "params": {"minuend": 42, "subtrahend": 23}, "id": 4})
    answers << %({"jsonrpc": "2.0", "result": 19, "id": 4})
    validates process, inputs, answers
  end
end

shared_examples 'a Notification' do
  it 'a Notification' do
    inputs  << %({"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]})
    answers << nil
    inputs  << %({"jsonrpc": "2.0", "method": "foobar"})
    answers << nil
    validates process, inputs, answers
  end
end

shared_examples 'rpc call of non-existent method' do
  it 'rpc call of non-existent method' do
    inputs  << %({"jsonrpc": "2.0", "method": "foobar", "id": "1"})
    answers << %({"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "1"})
    validates process, inputs, answers
  end
end

shared_examples 'rpc call with invalid JSON' do
  it 'rpc call with invalid JSON' do
    inputs  << %({"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz])
    answers << %({"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null})
    validates process, inputs, answers
  end
end

shared_examples 'rpc call with invalid Request object' do
  it 'rpc call with invalid Request object' do
    inputs  << %({"jsonrpc": "2.0", "method": 1, "params": "bar"})
    answers << %({"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null})
    validates process, inputs, answers
  end
end

shared_examples 'rpc call Batch, invalid JSON' do
  it 'rpc call Batch, invalid JSON' do
    inputs  << <<-JSON
      [
        {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
        {"jsonrpc": "2.0", "method"
      ]
    JSON
    answers << <<-JSON
      {"jsonrpc": "2.0", "error": {"code": -32700, "message": "Parse error"}, "id": null}
    JSON
    validates process, inputs, answers
  end
end

shared_examples 'rpc call with an empty Array' do
  it 'rpc call with an empty Array' do
    inputs  << %([])
    answers << %({"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null})
    validates process, inputs, answers
  end
end

shared_examples 'rpc call with an invalid Batch (but not empty)' do
  it 'rpc call with an invalid Batch (but not empty)' do
    inputs  << %([1])
    answers << <<-JSON
      [
        {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
      ]
    JSON
    validates process, inputs, answers
  end
end

shared_examples 'rpc call with invalid Batch' do
  it 'rpc call with invalid Batch' do
    inputs  << %([1,2,3])
    answers << <<-JSON
      [
        {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
        {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
        {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null}
      ]
    JSON
    validates process, inputs, answers
  end
end

shared_examples 'rpc call Batch' do
  it 'rpc call Batch' do
    inputs  << <<-JSON
      [
        {"jsonrpc": "2.0", "method": "sum", "params": [1,2,4], "id": "1"},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]},
        {"jsonrpc": "2.0", "method": "subtract1", "params": [42,23], "id": "2"},
        {"foo": "boo"},
        {"jsonrpc": "2.0", "method": "foo.get", "params": {"name": "myself"}, "id": "5"},
        {"jsonrpc": "2.0", "method": "get_data", "id": "9"} 
      ]
    JSON
    answers << <<-JSON
      [
        {"jsonrpc": "2.0", "result": 7, "id": "1"},
        {"jsonrpc": "2.0", "result": 19, "id": "2"},
        {"jsonrpc": "2.0", "error": {"code": -32600, "message": "Invalid Request"}, "id": null},
        {"jsonrpc": "2.0", "error": {"code": -32601, "message": "Method not found"}, "id": "5"},
        {"jsonrpc": "2.0", "result": ["hello", 5], "id": "9"}
      ]
    JSON
    validates process, inputs, answers
  end
end

shared_examples 'rpc call Batch (all notifications)' do
  it 'rpc call Batch (all notifications)' do
    inputs  << <<-JSON
      [
        {"jsonrpc": "2.0", "method": "notify_sum", "params": [1,2,4]},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7]}
      ]
    JSON
    answers << nil
    validates process, inputs, answers
  end
end

shared_examples 'returning valid response' do
  let(:inputs) { [] }
  let(:answers) { [] }
  include_examples 'rpc call with positional parameters'
  include_examples 'rpc call with named parameters'
  include_examples 'a Notification'
  include_examples 'rpc call of non-existent method'
  include_examples 'rpc call with invalid JSON'
  include_examples 'rpc call with invalid Request object'
  include_examples 'rpc call Batch, invalid JSON'
  include_examples 'rpc call with an empty Array'
  include_examples 'rpc call with an invalid Batch (but not empty)'
  include_examples 'rpc call with invalid Batch'
  include_examples 'rpc call Batch'
  include_examples 'rpc call Batch (all notifications)'
end
