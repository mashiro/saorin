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
    Saorin::Response.new options
  end

  describe '#initialize' do
    context 'success' do
      before { @r = Saorin::Response.new :result => '123', :id => 123 }
      subject { @r }
      its(:version) { should eq Saorin::JSON_RPC_VERSION }
      its(:result) { should eq '123' }
      its(:error) { should be_nil }
      its(:id) { should eq 123 }
      its(:error?) { should be_falsey }
    end

    context 'error' do
      before do
        @e = Saorin::InvalidRequest.new
        @r = Saorin::Response.new :error => @e, :id => 123
      end
      subject { @r }
      its(:version) { should eq Saorin::JSON_RPC_VERSION }
      its(:result) { should be_nil }
      its(:error) { should eq @e }
      its(:id) { should eq 123 }
      its(:error?) { should be_truthy }
    end
  end

  describe '#valid' do
    it 'version' do
      create_response(:version => '1.0').should_not be_valid
      create_response(:version => '2.0').should be_valid
      create_response(:version => 2).should_not be_valid
    end

    context 'result' do
      def create_success_response(result)
        create_response(:result => result, :error => nil)
      end

      it('number') { create_success_response(123).should be_valid }
      it('string') { create_success_response('123').should be_valid }
      it('nil') { create_success_response(nil).should be_valid }
      it('array') { create_success_response([]).should be_valid }
      it('hash') { create_success_response({}).should be_valid }
    end

    context 'error' do
      def create_fail_response(error)
        create_response(:result => nil, :error => error)
      end

      it('number') { create_fail_response(123).should_not be_valid }
      it('string') { create_fail_response('123').should_not be_valid }
      it('array') { create_fail_response([]).should_not be_valid }
      it('hash') { create_fail_response({}).should be_valid }
      it('exception') { create_fail_response(Saorin::InvalidResponse.new).should be_valid }
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
        lambda { r.validate }.should_not raise_error
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
    it 'error' do
      h = create_response(:error => nil).to_h
      h.should include('result')
      h.should_not include('error')
    end
  end
end
