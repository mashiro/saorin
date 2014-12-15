require 'spec_helper'

describe Saorin::Request do
  def create_request(options = {})
    default_options = {
      :version => Saorin::JSON_RPC_VERSION,
      :method => 'test',
      :params => [1, 2, 3],
      :id => rand(1 << 31),
    }
    options = default_options.merge(options)
    method = options.delete(:method)
    params = options.delete(:params)
    Saorin::Request.new method, params, options
  end

  describe '#initialize' do
    before { @r = create_request :method => 'test', :params => [1, 2, 3], :id => 123 }
    subject { @r }
    its(:version) { should eq Saorin::JSON_RPC_VERSION }
    its(:method) { should eq 'test' }
    its(:params) { should eq [1, 2, 3] }
    its(:id) { should eq 123 }
  end

  describe '#valid' do
    it 'version' do
      create_request(:version => '1.0').should_not be_valid
      create_request(:version => '2.0').should be_valid
      create_request(:version => 2).should_not be_valid
    end

    it 'method' do
      create_request(:method => '.test').should_not be_valid
      create_request(:method => 'test').should be_valid
      create_request(:method => 123).should_not be_valid
    end

    it 'params' do
      create_request(:params => 123).should_not be_valid
      create_request(:params => '123').should_not be_valid
      create_request(:params => nil).should be_valid
      create_request(:params => []).should be_valid
      create_request(:params => {}).should be_valid
    end

    it 'id' do
      create_request(:id => 123).should be_valid
      create_request(:id => '123').should be_valid
      create_request(:id => nil).should be_valid
      create_request(:id => []).should_not be_valid
      create_request(:id => {}).should_not be_valid
    end
  end

  describe '#validate' do
    context 'valid' do
      it do
        r = create_request
        r.stub(:valid?).and_return(true)
        lambda { r.validate }.should_not raise_error
      end
    end

    context 'invalid' do
      it do
        r = create_request
        r.stub(:valid?).and_return(false)
        lambda { r.validate }.should raise_error Saorin::InvalidRequest
      end
    end
  end

  describe '#to_h' do
    it 'with params' do
      h = create_request(:params => [1, 2, 3]).to_h
      h.should include('params')
    end
    it 'without params' do
      h1 = create_request(:params => nil).to_h
      h2 = create_request(:params => []).to_h
      h1.should_not include('params')
      h2.should_not include('params')
    end
  end

  describe '::from_hash' do
    it 'convertible' do
      r1 = create_request
      h1 = r1.to_h
      r2 = Saorin::Request.from_hash(h1)
      h2 = r2.to_h
      h1.should eq h2
    end
  end
end
