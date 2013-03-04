require 'spec_helper'

describe Saorin::Response do
  def create_response(options = {})
    default_options = {
      :version => Saorin::JSON_RPC_VERSION,
      :result => '123',
      :error => nil,
      :id => rand(1 << 31),
    }
    options = default_options.merge(options)
    Saorin::Response.new *options.values_at(:result, :error, :id, :version)
  end

  describe '#initialize' do
    context 'success' do
      before { @r = create_response :result => '123', :error => nil, :id => 123 }
      subject { @r }
      its(:version) { should eq Saorin::JSON_RPC_VERSION }
      its(:result) { should eq '123' }
      its(:error) { should be_nil }
      its(:id) { should eq 123 }
      its(:error?) { should be_false }
    end

    context 'fail' do
      before do
        @e = Saorin::InvalidRequest.new
        @r = create_response :result => nil, :error => @e, :id => 123
      end
      subject { @r }
      its(:version) { should eq Saorin::JSON_RPC_VERSION }
      its(:result) { should be_nil }
      its(:error) { should eq @e }
      its(:id) { should eq 123 }
      its(:error?) { should be_true }
    end
  end

  describe '#valid' do
    it 'version' do
      create_response(:version => '1.0').should_not be_valid
      create_response(:version => '2.0').should be_valid
      create_response(:version => 2).should_not be_valid
    end

    it 'result / error' do
      create_response(:error => nil, :result => 123).should_not be_valid
      create_response(:error => nil, :result => '123').should be_valid
      create_response(:error => nil, :result => []).should_not be_valid
      create_response(:error => nil, :result => {}).should_not be_valid

      create_response(:result => nil, :error => 123).should_not be_valid
      create_response(:result => nil, :error => '123').should_not be_valid
      create_response(:result => nil, :error => nil).should_not be_valid
      create_response(:result => nil, :error => []).should_not be_valid
      create_response(:result => nil, :error => {}).should be_valid
      create_response(:result => nil, :error => Saorin::InvalidResponse.new).should be_valid

      create_response(:error => nil, :result => nil).should_not be_valid
      create_response(:error => 123, :result => 123).should_not be_valid
    end

    it 'id' do
      create_response(:id => 123).should be_valid
      create_response(:id => '123').should be_valid
      create_response(:id => nil).should be_valid
      create_response(:id => []).should_not be_valid
      create_response(:id => {}).should_not be_valid
    end
  end

  describe '#validate' do
    context 'valid' do
      it do
        r = create_response
        r.stub(:valid?).and_return(true)
        lambda { r.validate }.should_not raise_error Saorin::InvalidResponse
      end
    end

    context 'invalid' do
      it do
        r = create_response
        r.stub(:valid?).and_return(false)
        lambda { r.validate }.should raise_error Saorin::InvalidResponse
      end
    end
  end

  describe '#to_h' do
    it 'success' do
      e = Saorin::InvalidRequest.new
      h = create_response(:error => e).to_h
      h.should_not include('result')
      h.should include('error')
    end
    it 'fail' do
      h = create_response(:error => nil).to_h
      h.should include('result')
      h.should_not include('error')
    end
  end
end
